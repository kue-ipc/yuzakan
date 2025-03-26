# frozen_string_literal: true

# Userレポジトリへの登録または更新
module Yuzakan
  module Management
    class RegisterUser < Yuzakan::Operation
      include Deps[
        "repos.user_repo",
        "repos.group_repo",
        "repos.member_repo",
        "management.sync_group",
      ]

      def call(username, params)
        transaction do
          username = step validate_name(username)
          params = step validate_params(params)
          step register(username, params)
        end
      end

      private def validate_params(params)
        validated_params = {
          **params.slice(:display_name, :email),
          deleted: false,
          deleted_at: nil,
        }

        if params.key?(:primary_group)
          validated_params[:group] =
            get_group(params[:primary_group])
              .value_or { return Failure(_1) }
        end

        if params.key?(:groups)
          validated_params[:groups] =
            (params[:groups] - [params[:primary_group]]).map do |groupname|
              get_group(groupname)
                .value_or { return Failure(_1) }
            end
        end

        Success(validated_params)
      end

      def register(username, params)
        user = user_repo.set(username, **params.except(:group, :groups),
          group_id: params[:group]&.id)

        if params.key?(:groups)
          member_repo.set_groups_for_user(user, params[:groups])
        end

        Success(user_repo.get_with_groups(username))
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
