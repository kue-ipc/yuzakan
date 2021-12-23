# Google Workspace Adapter
#
# CRUD
# create(username, **attrs) -> user or nil [writable]
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
require 'json'

require 'googleauth'
require 'google/apis/admin_directory_v1'

module Yuzakan
  module Adapters
    class GoogleAdapter < AbstractAdapter
      LABEL = 'Google Workspace'

      PARAMS = [
        {
          name: 'domain',
          label: 'Google Workspaceのドメイン名',
          description:
            'Google Workspaceでのドメイン名を指定します。',
          type: :string,
          required: true,
          placeholder: 'google.example.jp',
        }, {
          name: 'account',
          label: 'Google Workspaceの管理用アカウント',
          description:
            'Google Workspaceでユーザーに対する管理権限のあるアカウントを指定します。' \
            'このユーザーの権限にて各処理が実行されます。',
          type: :string,
          required: true,
          placeholder: 'admin@google.example.jp',
        }, {
          name: 'json_key',
          label: 'JSONキー',
          description:
            'Google Workspaceで作成したサービスアカウントのキーを貼り付けます。' \
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

      def self.selectable?
        true
      end

      def initialize(params)
        super
        @json_key_io = StringIO.new(@params[:json_key]) if @params[:json_key]
      end

      def check
        query = "email=#{@params[:account]}"
        response = service.list_users(domain: @params[:domain], query: query)
        response.users.size == 1
      end

      def create(username, password = nil, **attrs)
        user = specialize_user(attrs.merge(name: username))
        # set a password
        set_password(user, password)
        response = service.insert_user(user)
        if ['/教員', '/職員'].include?(user.org_unit_path)
          member = Google::Apis::AdminDirectoryV1::Member.new(email: user.primary_email)
          service.insert_member("classroom_teachers@#{@params[:domain]}", member)
        end
        normalize_user(response)
      end

      def read(username)
        email = "#{username}@#{@params[:domain]}"
        user = service.get_user(email)
        normalize_user(user)
      rescue Google::Apis::ClientError => e
        Hanami.logger.error e
        nil
      end

      def udpate(_username, **_attrs)
        raise NotImplementedError
      end

      def delete(username)
        email = "#{username}@#{@params[:domain]}"
        user = service.get_user(email)
        raise 'ユーザーが存在しません。' if user.nil?

        raise 'このシステムで、管理者を削除することはできません。' if user.is_admin?

        # pp email
        # service.delete_user(email)
      end

      def auth(_username, _password)
        raise NotImplementedError
      end

      def change_password(username, password)
        email = "#{username}@#{@params[:domain]}"
        user = service.get_user(email)
        raise 'ユーザーが存在しません。' if user.nil?

        raise 'このシステムで、管理者のパスワードを変更することはできません。' if user.is_admin?

        user = Google::Apis::AdminDirectoryV1::User.new
        set_password(user, password)
        user = service.patch_user(email, user)
        normalize_user(user)
      end

      def lock(_username)
        raise NotImplementedError
      end

      def unlock(username, password = nil)
        email = "#{username}@#{@params[:domain]}"
        user = service.get_user(email)
        raise 'ユーザーが存在しません。' if user.nil?

        raise 'このシステムで、管理者をアンロックすることはできません。' if user.is_admin?

        # ロックされていないユーザーはそのまま無視して、nilを返す。
        return unless user.suspended?

        raise 'このシステムでは、無効状態を解除できません。' if user.suspension_reason != 'ADMIN'

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

      def generate_code(username)
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

      private def normalize_user(user)
        return if user.nil?

        data = {
          name: user.primary_email.split('@').first,
          display_name: user.name.full_name,
          email: user.primary_email,
        }

        if user.suspended?
          # ADMIN: 管理者が停止
          # ABUSE: 不正行為により停止(利用も削除も不可)
          # UNDER13: 13歳未満のため
          # WEB_LOGIN_REQUIRED: ログイン前新規アカウント(使用され無い)
          # null: その他の自動停止中
          if user.suspension_reason == 'ADMIN'
            data[:locked] = true
          else
            data[:disabled] = true
          end
        end

        data[:unmanageable] = true if user.is_admin?

        data[:mfa] =
          if user.is_enforced_in2_sv?
            :enforced
          elsif user.is_enrolled_in2_sv?
            :enabled
          end

        JSON.parse(user.to_json).each do |key, value|
          if key == 'name'
            value.each do |name_key, name_value|
              data["name.#{name_key}"] = name_value
            end
          else
            data[key] = value
          end
        end

        data
      end

      private def specialize_user(attrs)
        name = Google::Apis::AdminDirectoryV1::UserName.new(
          given_name: attrs['name.givenName'],
          family_name: attrs['name.familyName'])
        user = Google::Apis::AdminDirectoryV1::User.new(
          primary_email: "#{attrs[:name]}@#{@params[:domain]}",
          name: name)
        user.org_unit_path = attrs['orgUnitPath'] if attrs['orgUnitPath']

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
        json_name.gsub(/[A-Z]/) { |s| "_#{s.downcase}" }
      end

      private def name_ruby_to_json(ruby_name)
        ruby_name.gsub(/_([a-z])/) { |s| s[0].upcaes }
      end
    end
  end
end
