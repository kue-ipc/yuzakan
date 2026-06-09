# frozen_string_literal: true

# Userレポジトリと各プロバイダーのユーザー情報を同期し、ユーザーを返す。
module Yuzakan
  module Management
    class SyncUser < Yuzakan::Operation
      include Deps[
        "services.read_user",
        "management.register_user",
        "management.unregister_user"
      ]

      def call(username)
        username = step validate_name(username)
        params = step read(username)
        step sync(username, params)
      end

      private def read(username)
        services = read_user.call(username).value_or { return Failure(_1) }
        return Success(nil) if services.empty?

        params = {
          groups: [],
          unmanageable: false,
          locked: false,
          mfa: false,
          attrs: {},
          services: services.keys,
        }
        services.each_value do |data|
          params[:groups] |= data[:groups] if data.key?(:groups)
          [:primary_group, :label, :email, :unmanageable, :locked, :mfa].each do |name|
            params[name] ||= data[name] if data.key?(name)
          end
          params[:attrs].merge!(data[:attrs]) { |_, v, _| v } if data.key?(:attrs)
        end
        Success(params)
      end

      private def sync(username, params)
        if params
          register_user.call(username, params)
        else
          unregister_user.call(username)
        end
      end
    end
  end
end
