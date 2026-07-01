# frozen_string_literal: true

# Userレポジトリへの登録または更新
module Yuzakan
  module Management
    class RegisterUser < Yuzakan::Operation
      include Deps[
        "repos.user_repo",
        "repos.group_repo",
        "repos.member_repo",
        "repos.managed_user_repo",
        "management.sync_group",
        "management.complete_user",
      ]

      def call(username, params, time: Time.now)
        username = step validate_name(username)
        primary_group = step get_group(params[:primary_group])
        groups = params[:groups].map { |groupname| step get_group(groupname) }.compact
        user_params = step complete_user.call(username, params[:attrs], primary_group, groups)
        user_params = user_params.merge({
          affiliation_id: primary_group&.affiliation_id,
          group_id: primary_group&.id,
          deleted_at: nil,
          synced_at: time,
        })
        services = params[:services]

        user_repo.transaction do
          user = user_repo.set(username, **user_params)
          member_repo.set_groups_for_user(user, groups)
          managed_user_repo.set_services_for_user(user, services)
        end

        user_repo.get_with_associations(username)
      end

      private def get_group(groupname)
        return Success(nil) if groupname.nil?

        group = group_repo.get(groupname)
        return Success(group) if group

        sync_group.call(groupname)
      end
    end
  end
end
