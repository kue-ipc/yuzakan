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
        time = Time.now
        params = step read(username)
        step sync(username, params, time:)
      end

      private def read(username)
        params = {
          groups: [],
          attrs: {},
          locked_count: 0,
          services: [],
        }

        service_repo.all.each do |service|
          result = read_user.call(service, username).value_or { return Failure(_1) }
          next unless result

          if result.key?(:primary_group)
            params[:primary_group] ||= result[:primary_group]
            params[:groups] |= [result[:primary_group]]
          end
          params[:groups] |= result[:groups] if result.key?(:groups)
          params[:attrs] = result[:attrs].merge(params[:attrs]) if result[:attrs]
          params[:locked_count] += 1 if result[:locked]
          params[:services] << service
        end

        return Success(nil) if params[:services].empty?

        params[:groups] -= [params[:primary_group]] if params[:primary_group]
        params[:groups] = params[:groups].uniq.compact
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
