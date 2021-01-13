# G Suite Adapter
#
# CRUD
# create(username, attrs) -> user or nil [writable]
# read(username) -> user or nil [readable]
# update(username, attrs) -> user or nil [writeable]
# delete(username) -> user or nil [writable]
#
# auth(username, password) -> user or nil [authenticatable]
# change_password(username, password) -> user ro nil [password_changeable]
#
# lock(username) -> locked?(username) [lockable]
# unlock(username) -> locked?(username) [lockable]
# locked?(username) -> true or false [lockable]
#
# list -> usernames [readable]

require 'stringio'
require 'securerandom'

require 'googleauth'
require 'google/apis/admin_directory_v1'

module Yuzakan
  module Adapters
    class GsuiteAdapter < AbstractAdapter
      def self.label
        'G Suite'
      end

      def self.selectable?
        true
      end

      self.params = [
        {
          name: 'domain',
          label: 'G Suiteのドメイン名',
          description:
            'G Suiteでのドメイン名を指定します。',
          type: :string,
          required: true,
          placeholder: 'google.example.jp',
        }, {
          name: 'account',
          label: 'G Suiteの管理用アカウント',
          description:
            'G Suiteでユーザーに対する管理権限のあるアカウントを指定します。' \
            'このユーザーの権限にて各処理が実行されます。',
          type: :string,
          required: true,
          placeholder: 'admin@google.example.jp',
        }, {
          name: 'json_key',
          label: 'JSONキー',
          description:
            'G Suiteで作成したサービスアカウントのキーを貼り付けます。' \
            'ドメイン全体の委任が有効でなければなりません。',
          type: :text,
          rows: 20,
          required: true,
          placeholder: <<~'PLACE_H',
            {
              "type": "service_account",
              "project_id": "yuzakan-...
          PLACE_H
          encrypted: true,
        },
      ]

      def initialize(params)
        super
        @json_key_io = StringIO.new(@params[:json_key]) if @params[:json_key]
      end

      def check
        query = "email=#{@params[:account]}"
        response = service.list_users(domain: @params[:domain], query: query)
        response.users.size == 1
      end

      def create(username, attrs, mappings, password)
        user = specialize_user(attrs.merge(name: username), mappings)
        # set a password
        set_password(user, password)
        response = service.insert_user(user)
        if ['/教員', '/職員'].include?(user.org_unit_path)
          member = Google::Apis::AdminDirectoryV1::Member.new(
            email: user.primary_email)
          service.insert_member(
            'classroom_teachers@' + @params[:domain],
            member)
        end
        normalize_user(response, mappings)
      end

      def read(username, mappings = nil)
        email = "#{username}@#{@params[:domain]}"
        user = service.get_user(email)
        normalize_user(user, mappings)
      rescue Google::Apis::ClientError => e
        Hanami.logger.debug 'GsuiteAdapter#read: ' + e.message
        nil
      end

      def udpate(_username, _attrs, mappings = nil)
        raise NotImplementedError
      end

      def delete(username)
        email = "#{username}@#{@params[:domain]}"
        user = service.get_user(email)
        raise 'ユーザーが存在しません。' if user.nil?

        raise 'このシステムで、管理者を削除することはできません。' if user.is_admin?

        pp email
        # service.delete_user(email)
      end

      def auth(_username, _password)
        raise NotImplementedError
      end

      def change_password(username, password, mappings = nil)
        email = "#{username}@#{@params[:domain]}"
        user = service.get_user(email)
        raise 'ユーザーが存在しません。' if user.nil?

        raise 'このシステムで、管理者のパスワードを変更することはできません。' if user.is_admin?

        user = Google::Apis::AdminDirectoryV1::User.new
        set_password(user, password)
        user = service.patch_user(email, user)
        normalize_user(user, mappings)
      end

      def lock(_username)
        raise NotImplementedError
      end

      def unlock(username, password = nil)
        email = "#{username}@#{@params[:domain]}"
        user = service.get_user(email)
        raise 'ユーザーが存在しません。' if user.nil?

        raise 'このシステムで、管理者をアンロックすることはできません。' if user.is_admin?

        user = Google::Apis::AdminDirectoryV1::User.new(
          suspended: false)
        set_password(user, password) if password
        user = service.patch_user(email, user)
        normalize_user(user)
      end

      def locked?(_username)
        raise NotImplementedError
      end

      def list
        users = []
        next_page_token = nil
        # 最大でも20回で10,000ユーザーしか取得できない
        20.times do
          response = service.list_users(domain: @params[:domain],
                                        max_results: 500,
                                        page_token: next_page_token)
          users.concat(response.users
            .map(&:primary_email)
            .map { |email| email.split('@', 2) }
            .select { |_name, domain| domain == @params[:domain] }
            .map(&:first))
          next_page_token = response.next_page_token
          break unless next_page_token
        end
        users
      end

      def generate_verification_code(username)
        user = read(username)
        unless user[:mfa]
          # 2段階認証が有効でないユーザー
          return
        end

        service.generate_verification_code(user[:email])
        result = service.list_verification_codes(user[:email])
        result.items&.map(&:verification_code)
      end

      private def service
        @service ||= Google::Apis::AdminDirectoryV1::DirectoryService.new
          .tap { |sv| sv.authorization = authorizer }
      end

      private def authorizer
        @authorizer ||= Google::Auth::ServiceAccountCredentials
          .make_creds(scope: scope, json_key_io: @json_key_io)
          .tap { |auth| auth.sub = @params[:account] }
          .tap(&:fetch_access_token!)
      end

      private def scope
        [
          Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_USER,
          Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_GROUP,
          Google::Apis::AdminDirectoryV1::AUTH_ADMIN_DIRECTORY_USER_SECURITY,
        ]
      end

      # 現在のところ CRYPT-MD5のみ実装
      # slappasswd -h '{CRYPT}' -c '$1$%.8s'
      # $1$vuIZLw8r$d9mkddv58FuCPxOh6nO8f0
      private def generate_password(password)
        salt = SecureRandom.base64(12).gsub('+', '.')
        password.crypt(format('$1$%.8s', salt))
      end

      private def normalize_user(user, mappings = nil)
        return if user.nil?

        data = {
          name: user.primary_email.split('@').first,
          display_name: user.name.full_name,
          email: user.primary_email,
          state: :available,
        }
        if user.suspended?
          case user.suspension_reason
          when 'ADMIN'
            data[:state] = :locked
          when 'ABUSE', 'UNDER13'
            data[:state] = :disabled
          end
        end

        data[:admin] = user.is_admin?

        data[:mfa] =
          if user.is_enforced_in2_sv?
            :enforced
          elsif user.is_enrolled_in2_sv?
            :enabled
          end

        if mappings
          mappings.each do |mapping|
            name_list = mapping.name.split('.')
            value = name_list.inject(user) do |result, name|
              result&.__send__(name_json_to_ruby(name))
            end
            next if value.nil?

            data[mapping.attr.name.intern] = mapping.convert(value)
          end
        end

        data
      end

      private def specialize_user(attrs, mappings)
        mapped_attrs = {
          'primaryEmail' => "#{attrs[:name]}@#{@params[:domain]}",
        }
        mappings.each do |mapping|
          mapped_attrs[mapping.name] =
            mapping.reverse_convert(attrs[mapping.attr.name.intern])
        end

        user = Google::Apis::AdminDirectoryV1::User.new(
          primary_email: mapped_attrs['primaryEmail'],
          name: Google::Apis::AdminDirectoryV1::UserName.new(
            given_name: mapped_attrs['name.givenName'],
            family_name: mapped_attrs['name.familyName']))

        if mapped_attrs['orgUnitPath']
          user.org_unit_path = mapped_attrs['orgUnitPath']
        end

        user
      end

      # パスワードを設定する。
      # CRYPT MD5形式を使用する。
      # 次回ログイン時パスワード変更を有効にする。
      # TODO: 次回ログイン時は選べるようにしておく。
      private def set_password(user, password)
        user.password = generate_password(password)
        user.hash_function = 'crypt'
        user.change_password_at_next_login = true
      end

      private def name_json_to_ruby(json_name)
        json_name.gsub(/[A-Z]/) { |s| '_' + s.downcase }
      end

      private def name_ruby_to_json(ruby_name)
        ruby_name.gsub(/_([a-z])/) { |s| s[0].upcaes }
      end
    end
  end
end
