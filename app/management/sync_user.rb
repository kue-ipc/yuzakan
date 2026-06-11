# frozen_string_literal: true

# 各サービスと同期し、ユーザーを返す。
module Yuzakan
  module Management
    class SyncUser < Yuzakan::Operation
      include Deps[
        "repos.service_repo",
        "services.read_user",
        "management.register_user",
        "management.unregister_user",
      ]

      def call(username)
        username = step validate_name(username)
        params = step read(username)
        step sync(username, params)
      end

      private def read(username)
        params = {
          groups: [],
          unmanageable: false,
          locked: false,
          mfa: false,
          attrs: {},
          services: [],
        }

        service_repo.all.each do |service|
          result = read_user.call(service, username).value_or { return Failure(_1) }
          next unless result

          params[:groups] |= result[:groups] if result.key?(:groups)
          [:primary_group, :label, :email, :unmanageable, :locked, :mfa].each do |name|
            params[name] ||= result[name] if result.key?(name)
          end
          params[:attrs].merge!(result[:attrs]) { |_, v, _| v } if result.key?(:attrs)
          params[:services] << service
        end

        return Success(nil) if params[:services].empty?

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
