# frozen_string_literal: true

require "yaml"
require "bcrypt"
require "securerandom"

module Yuzakan
  module Adapters
    class Mock < Yuzakan::Adapter
      version "0.1.0"
      hidden Hanami.env?(:production)
      group true
      primary true

      json do
        required(:check).filled(:bool?)
        required(:username).filled(:str?, max_size?: 255)
        required(:password).filled(:str?, max_size?: 255)
        required(:display_name).filled(:str?, max_size?: 255)
        required(:email).filled(:str?, max_size?: 255)
        optional(:locked).value(:bool?)
        optional(:unmanageable).value(:bool?)
        optional(:mfa).value(:bool?)
        optional(:primary_group).value(:str?, max_size?: 255)
        optional(:groups).value(:str?, max_size?: 255)
        optional(:attrs).value(:str?, max_size?: 65535)
      end

      # self.params = [
      #   {
      #     name: :check,
      #     label: "チェック",
      #     type: :boolean,
      #     default: true,
      #   },
      #   {
      #     name: :username,
      #     label: "ユーザー名",
      #     type: :string,
      #     default: "user",
      #   },
      #   {
      #     name: :password,
      #     label: "パスワード",
      #     type: :string,
      #     default: "password",
      #   },
      #   {
      #     name: :display_name,
      #     label: "表示名",
      #     type: :string,
      #     default: "ユーザー",
      #   },
      #   {
      #     name: :email,
      #     label: "メールアドレス",
      #     type: :string,
      #     default: "user@example.jp",
      #   },
      #   {
      #     name: :locked,
      #     label: "ロック済み",
      #     type: :boolean,
      #     default: false,
      #   },
      #   {
      #     name: :unmanageable,
      #     label: "管理不可",
      #     type: :boolean,
      #     default: false,
      #   },
      #   {
      #     name: :mfa,
      #     label: "多要素認証",
      #     type: :boolean,
      #     default: false,
      #   },
      #   {
      #     name: :primary_group,
      #     label: "プライマリーグループ",
      #     type: :string,
      #     default: "",
      #   },
      #   {
      #     name: :groups,
      #     label: "グループ",
      #     type: :string,
      #     description: "カンマまたは空白区切り",
      #     default: "",
      #   },
      #   {
      #     name: :attrs,
      #     label: "属性",
      #     type: :text,
      #     default: "",
      #     description: "YAML形式で記入",
      #   },
      # ].tap(&Yuzakan::Utils::Object.method(:deep_freeze))

      def initialize(params, **opts)
        super
        @passwords = {@params[:username] => BCrypt::Password.create(@params[:password])}
        primary_group = @params[:primary_group]
        primary_group = nil if primary_group&.empty?
        groups = @params[:groups].to_s.split(/\s|,/).map(&:strip).reject(&:empty?)
        @users = {@params[:username] => {
          username: @params[:username],
          display_name: @params[:display_name],
          email: @params[:email],
          locked: @params[:locked],
          unmanageable: @params[:unmanageable],
          mfa: @params[:mfa],
          primary_group: primary_group,
          groups: groups,
          attrs: YAML.safe_load(@params[:attrs]),
        }}
        @groups = [primary_group, *groups].uniq.compact.to_h do |name|
          [name, {groupname: name, display_name: name}]
        end
      end

      def check
        @params[:check]
      end

      def create(username, password = nil, **userdata)
        raise AdapterError, "ユーザーは既に存在します。" if @users.key?(username)

        @passwords[username] = BCrypt::Password.create(password) if password
        @users[username] = {
          username: username,
          **userdata,
        }
      end

      def user_read(username)
        @users[username]
      end

      def user_update(username, **userdata)
        return nil unless @users.key?(username)
        raise AdapterError, "管理不可ユーザーであるため、更新できません。" if @users.dig(username,
          :unmanageable)

        @users[username] = @users[username].merge(userdata) do |_key, self_val, other_val|
          if self_val.is_a?(Hash)
            self_val.merge(other_val)
          else
            other_val
          end
        end
      end

      def user_delete(username)
        return nil unless @users.key?(username)
        raise AdapterError, "管理不可ユーザーであるため、削除できません。" if @users.dig(username,
          :unmanageable)

        @users[username]
      end

      def user_auth(username, password)
        user = @users[username]
        return false if user.nil?
        return false if user[:locked]

        @passwords[username]&.==(password)
      end

      def user_change_password(username, password)
        return nil unless @users.key?(username)
        raise AdapterError, "管理不可ユーザーであるため、パスワードを変更できません。" if @users.dig(
          username, :unmanageable)

        @passwords[username] = BCrypt::Password.create(password)
        @users[username]
      end

      def user_generate_code(username)
        return nil unless @users.key?(username)
        raise AdapterError, "管理不可ユーザーであるため、バックアップコードを生成できません。" if @users.dig(
          username, :unmanageable)

        10.times.map { SecureRandom.alphanumeric }
      end

      def user_lock(username)
        return nil unless @users.key?(username)
        raise AdapterError, "管理不可ユーザーであるため、ロックできません。" if @users.dig(username,
          :unmanageable)

        @users[username][:locked] = true
        @users[username]
      end

      def user_unlock(username, password = nil)
        return nil unless @users.key?(username)
        raise AdapterError, "管理不可ユーザーであるため、アンロックできません。" if @users.dig(username,
          :unmanageable)

        user_change_password(usename, password) if password

        @users[username][:locked] = false
        @users[username]
      end

      def user_list
        @users.keys
      end
    end
  end
end
