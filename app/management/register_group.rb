# frozen_string_literal: true

# Groupレポジトリへの登録または更新
module Yuzakan
  module Management
    class RegisterGroup < Yuzakan::Operation
      include Deps[
        "repos.group_repo",
        "repos.managed_group_repo",
      ]

      def call(groupname, params, time: Time.now)
        groupname = step validate_name(groupname)
        params = step validate_params(params)
        step register(groupname, params, time:)
      end

      private def validate_params(params)
        Success(params.slice(:label, :unmanageable, :attrs, :services))
      end

      private def register(groupname, params, time: Time.now)
        group_repo.transaction do
          group_params = params.except(:services)
          group = group_repo.set(groupname, **group_params, deleted_at: nil, synced_at: time)
          managed_group_repo.set_services_for_group(group, params[:services]) if params.key?(:services)
        end
        Success(group_repo.get_with_associations(groupname))
      end
    end
  end
end
