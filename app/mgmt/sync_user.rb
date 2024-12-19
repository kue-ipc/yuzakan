# frozen_string_literal: true

# Userレポジトリと各プロバイダーのユーザー情報を同期し、ユーザーを返す。
module Yuzakan
  module Mgmt
    class SyncUser < Yuzakan::Operation
      include Deps[
        "providers.read_user",
        "users.register",
        "users.unregister",
      ]

      def call(username)
        username = step validate_name(username)
        user_params = step read(username)
        step sync(username, user_params)
      end

      private def read(username)
        providers = step read_user.call(username)

        return Success(nil) if providers.empty?

        user_params = {groups: []}
        providers.each_value do |data|
          %i[display_name email primary_group].each do |name|
            user_params[name] ||= data[name] unless data[name].nil?
          end
          user_params[:groups] |= data[:groups] unless data[:groups].nil?
        end
        Success(user_params)
      end

      private def sync(username, user_params)
        if user_params
          step register.call(username, user_params)
        else
          step unregister.call(username)
        end
      end
    end
  end
end
