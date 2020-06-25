# frozen_string_literal: true

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
        @json_key_io = StringIO.new(@params[:json_key])
      end

      def check
        query = "email=#{@params[:account]}"
        response = service.list_users(domain: @params[:domain], query: query)
        response.users.size == 1
      end

      def create(username, attrs, mappings, password)
        user = specialize_user(attrs.merge(name: username), mappings)
        # set a dummy password
        set_password(user, password)
        response = service.insert_user(user)
        response
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
        if user.nil?
          raise 'ユーザーが存在しません。'
        end

        if user.is_admin?
          raise 'このシステムで、管理者を削除することはできません。'
        end

        pp email
        # service.delete_user(email)
      end

      def auth(_username, _password)
        raise NotImplementedError
      end

      def change_password(username, password, mappings = nil)
        email = "#{username}@#{@params[:domain]}"
        user = service.get_user(email)
        if user.nil?
          raise 'ユーザーが存在しません。'
        end

        if user.is_admin?
          raise 'このシステムで、管理者のパスワードを変更することはできません。'
        end

        user = Google::Apis::AdminDirectoryV1::User.new
        set_password(user, password)
        user = service.patch_user(email, user)
        normalize_user(user, mappings)
      end

      def lock(_username)
        raise NotImplementedError
      end

      def unlock(_username)
        raise NotImplementedError
      end

      def locked?(_username)
        raise NotImplementedError
      end

      def list
        response = service.list_users(domain: @params[:domain])
        response.users
          .map(&:primary_email)
          .map { |email| email.split('@', 2) }
          .select { |_name, domain| domain == @params[:domain] }
          .map(&:first)
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
        }

        if mappings
          mappings.each do |mapping|
            name_list = mapping.name.split('.')
            value = name_list.inject(user) do |result, name|
              result.__send__(name_json_to_ruby(name))
            end
            next if value.nil?

            data[mapping.attr_type.name.intern] = mapping.convert(value)
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
            mapping.reverse_convert(attrs[mapping.attr_type.name.intern])
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
