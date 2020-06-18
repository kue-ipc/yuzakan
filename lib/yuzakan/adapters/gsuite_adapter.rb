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

      def create(username, attrs, mappings = nil)
        user = Google::Apis::AdminDirectoryV1::User.new(
          primary_email: "#{username}@#{@params[:domain]}",
          name: Google::Apis::AdminDirectoryV1::UserName.new(
            given_name: attrs[:given_name],
            family_name: attrs[:family_name],
          ),
          password: generate_password(attrs[:password]),
          hash_function: 'crypt')
        
        user.org_unit_path = ('/' + attrs[:ou]).gsub(%r{//+}, '/') if attrs[:ou]
        
        response = service.inseart_user(user)
        response
      end

      def read(username, mappings = nil)
        query = "email=#{username}@#{@params[:domain]}"
        response = service.list_users(domain: @params[:domain], query: query)
        user = response.users&.first
        normalize_user(user) if user
      end

      def udpate(_username, _attrs, mappings = nil)
        raise NotImplementedError
      end

      def delete(_username)
        raise NotImplementedError
      end

      def auth(_username, _password)
        raise NotImplementedError
      end

      def change_password(_username, _password)
        raise NotImplementedError
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

      private def normalize_user(gsuite_user)
        email = gsuite_user.primary_email
        name, domain = email.split('@', 2)
        user = {
          name: name,
          display_name: gsuite_user.name.full_name,
          email: email,
        }
        user
      end
    end
  end
end
