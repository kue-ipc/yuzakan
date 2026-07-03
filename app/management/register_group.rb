# frozen_string_literal: true

# Groupレポジトリへの登録または更新
module Yuzakan
  module Management
    class RegisterGroup < Yuzakan::Operation
      include Deps[
        "repos.group_repo",
        "repos.managed_group_repo",
        "management.complete_group",
      ]

      def call(groupname, params, time: Time.now)
        groupname = step validate_name(groupname)
        affiliation = step get_affiliation_for(groupname)
        group_params = step complete_group.call(groupname, params[:attrs], affiliation)
        group_params = group_params.merge({deleted_at: nil, synced_at: time})
        services = params[:services]

        group_repo.transaction do
          group = group_repo.set(groupname, **group_params)
          managed_group_repo.set_services_for_group(group, services)
        end

        group_repo.get_with_associations(groupname)
      end

      private def get_affiliation_for(groupname)
        group = group_repo.get_with_associations(groupname)
        Success(group&.affiliation)
      end
    end
  end
end
