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
      ]

      def call(username, params, time: Time.now)
        username = step validate_name(username)
        params = step validate_params(params)
        step register(username, params, time:)
      end

      private def validate_params(params)
        validated_params = params.slice(:label, :email, :attrs)
        if params.key?(:primary_group)
          primary_group = step get_group(params[:primary_group])
          validated_params[:group_id] = primary_group&.id
        end
        if params.key?(:groups)
          validated_params[:member_groups] = params[:groups].map do |groupname|
            step get_group(groupname)
          end.compact
        end
        if params.key?(:services)
          validated_params[:services] = params[:services].map do |service, service_params|
            [service, service_params.slice(:unmanageable, :locked, :mfa)]
          end
        end
        Success(validated_params)
      end

      private def register(username, params, time: Time.now)
        user_repo.transaction do
          user_params = params.except(:member_groups, :services)
          user = user_repo.set(username, **user_params, deleted_at: nil, synced_at: time)
          member_repo.set_groups_for_user(user, params[:member_groups]) if params.key?(:member_groups)
          managed_user_repo.set_services_for_user(user, params[:services]) if params.key?(:services)
        end
        Success(user_repo.get_with_associations(username))
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
