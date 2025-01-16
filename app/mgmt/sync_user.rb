# frozen_string_literal: true

# Userレポジトリと各プロバイダーのユーザー情報を同期し、ユーザーを返す。
module Yuzakan
  module Mgmt
    class SyncUser < Yuzakan::Operation
      include Deps[
        "providers.read_user",
        "mgmt.register_users",
        "mgmt.unregister_users",
      ]

      def call(username)
        username = step validate_name(username)
        params = step read_user(username)
        step sync_user(username, params)
      end

      private def read_user(username)
        providers = read_user.call(username)
          .value_or { |failure| return Failure(failure) }
        return Success(nil) if providers.empty?

        params = {groups: []}
        providers.each_value do |data|
          [:display_name, :email, :primary_group].each do |name|
            params[name] ||= data[name] if data.key?(name)
          end
          params[:groups] |= data[:groups] if data.key?(:groups)
        end
        Success(params)
      end

      private def sync_user(username, params)
        if params
          register_user.call(username, params)
        else
          unregister_user.call(username)
        end
      end
    end
  end
end
