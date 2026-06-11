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
        step sync(username, params, time: Time.now)
      end

      private def read(username)
        params = {
          groups: [],
          attrs: {},
          services: [],
        }

        service_repo.all.each do |service|
          result = read_user.call(service, username).value_or { return Failure(_1) }
          next unless result

          [:primary_group, :label, :email].each do |name|
            params[name] ||= result[name] if result.key?(name)
          end
          params[:groups] |= result[:groups] if result.key?(:groups)
          params[:groups] |= [result[:primary_group]] if result.key?(:primary_group)
          params[:attrs].merge!(result[:attrs]) { |_, v, _| v } if result.key?(:attrs)
          params[:services] << [service, result.slice(:unmanageable, :locked, :mfa)]
        end
        params[:groups] -= [params[:primary_group]] if params[:primary_group]
        params[:groups] = params[:groups].uniq.compact

        return Success(nil) if params[:services].empty?

        Success(params)
      end

      private def sync(username, params, time: Time.now)
        if params
          register_user.call(username, params, time:)
        else
          unregister_user.call(username, time:)
        end
      end
    end
  end
end
