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

      def call(username, params)
        username = step validate_name(username)
        params = step validate_params(params)
        step register(username, params)
      end

      private def validate_params(params)
        validated_params = params.slice(:label, :email, :unmanageable, :locked, :mfa, :attrs)

        if params.key?(:primary_group)
          validated_params[:primary_group] = get_group(params[:primary_group]).value_or { return Failure(_1) }
        end

        if params.key?(:groups)
          validated_params[:groups] = params[:groups].map do |groupname|
            get_group(groupname).value_or { return Failure(_1) }
          end
        end

        Success(validated_params)
      end

      def register(username, params)
        user_repo.transaction do
          user_params = params.slice(:label, :email, :unmanageable, :locked, :mfa, :attrs)
          user_params[:group_id] = params[:primary_group]&.id if params.key?(:primary_group)
          user_params[:deleted_at] = nil
          user = user_repo.set(username, **user_params)
          member_repo.set_groups_for_user(user, params[:groups]) if params.key?(:groups)
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
