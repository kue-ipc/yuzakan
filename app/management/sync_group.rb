# frozen_string_literal: true

# 各サービスと同期し、グループを返す。
module Yuzakan
  module Management
    class SyncGroup < Yuzakan::Operation
      include Deps[
        "repos.service_repo",
        "services.read_group",
        "management.register_group",
        "management.unregister_group",
      ]

      def call(groupname)
        groupname = step validate_name(groupname)
        params = step read(groupname)
        step sync(groupname, params, time: Time.now)
      end

      private def read(groupname)
        params = {
          attrs: {},
          services: [],
        }

        service_repo.all.each do |service|
          result = read_group.call(service, groupname).value_or { return Failure(_1) }
          next unless result

          [:label].each do |name|
            params[name] ||= result[name] if result.key?(name)
          end
          params[:attrs].merge!(result[:attrs]) { |_, v, _| v } if result.key?(:attrs)
          params[:services] << [service, result.slice(:unmanageable)]
        end

        return Success(nil) if params[:services].empty?

        Success(params)
      end

      private def sync(groupname, params, time: Time.now)
        if params
          register_group.call(groupname, params, time:)
        else
          unregister_group.call(groupname, time:)
        end
      end
    end
  end
end
