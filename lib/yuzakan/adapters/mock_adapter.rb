require 'yaml'
require 'bcrypt'
require 'securerandom'

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class MockAdapter < AbstractAdapter
      self.hidden_adapter = true if Hanami.env == 'production'

      self.name = 'mock'
      self.label = 'モック'
      self.version = '0.0.1'
      self.params = [
        {
          name: :check,
          label: 'チェック',
          type: :boolean,
          default: true,
        },
        {
          name: :username,
          label: 'ユーザー名',
          type: :string,
          default: 'user',
        },
        {
          name: :password,
          label: 'パスワード',
          type: :string,
          default: 'password',
        },
        {
          name: :display_name,
          label: '表示名',
          type: :string,
          default: 'ユーザー',
        },
        {
          name: :email,
          label: 'メールアドレス',
          type: :string,
          default: 'user@example.jp',
        },
        {
          name: :locked,
          label: 'ロック済み',
          type: :boolean,
          default: false,
        },
        {
          name: :disabled,
          label: '無効',
          type: :boolean,
          default: false,
        },
        {
          name: :unmanageable,
          label: '管理不可',
          type: :boolean,
          default: false,
        },
        {
          name: :mfa,
          label: '多要素認証',
          type: :boolean,
          default: false,
        },
        {
          name: :attrs,
          label: '属性',
          type: :text,
          default: '',
          description: 'YAML形式で記入',
        },
      ]

      def initialize(params, **opts)
        super
        @passwords = {@params[:username] => BCrypt::Password.create(@params[:password])}
        @users = {@params[:username] => {
          name: @params[:username],
          display_name: @params[:display_name],
          email: @params[:email],
          locked: @params[:locked],
          disabled: @params[:disabled],
          unmanageable: @params[:unmanageable],
          mfa: @params[:mfa],
          attrs: YAML.safe_load(@params[:attrs]),
        }}
      end

      def check
        @params[:check]
      end

      def create(username, password = nil, **userdata)
        raise Error, 'ユーザーは既に存在します。' if @users.key?(username)

        @passwords[username] = BCrypt::Password.create(password) if password
        @users[username] = {
          name: username,
          **userdata,
        }
      end

      def read(username)
        @users[username]
      end

      def udpate(username, **userdata)
        return nil unless @users.key?(username)
        raise Error, '管理不可ユーザーであるため、更新できません。' if @users.dig(username, :unmanageable)

        @users[username] = @users[username].merge(userdata) do |_key, self_val, other_val|
          if self_val.is_a?(Hash)
            self_val.merge(other_val)
          else
            other_val
          end
        end
      end

      def delete(username)
        return nil unless @users.key?(username)
        raise Error, '管理不可ユーザーであるため、削除できません。' if @users.dig(username, :unmanageable)

        @users[username]
      end

      def auth(username, password)
        @passwords[username]&.==(password) &&
          [:locked, :disabled].none? { |flag| @users.dig(username, flag) }
      end

      def change_password(username, password)
        return nil unless @users.key?(username)
        raise Error, '管理不可ユーザーであるため、パスワードを変更できません。' if @users.dig(username, :unmanageable)

        @passwords[username] = BCrypt::Password.create(password)
        @users[username]
      end

      def generate_code(username)
        return nil unless @users.key?(username)
        raise Error, '管理不可ユーザーであるため、バックアップコードを生成できません。' if @users.dig(username, :unmanageable)

        10.times.map { SecureRandom.alphanumeric }
      end

      def lock(username)
        return nil unless @users.key?(username)
        raise Error, '管理不可ユーザーであるため、ロックできません。' if @users.dig(username, :unmanageable)

        @users[username][:locked] = true
        @users[username]
      end

      def unlock(username, password = nil)
        return nil unless @users.key?(username)
        raise Error, '管理不可ユーザーであるため、アンロックできません。' if @users.dig(username, :unmanageable)

        change_password(usename, password) if password

        @users[username][:locked] = false
        @users[username]
      end

      def list
        @users.keys
      end
    end
  end
end
