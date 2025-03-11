# frozen_string_literal: true

# Userレポジトリへの登録または更新
module Yuzakan
  module Mgmt
    class RegisterUser < Yuzakan::Operation
      include Deps[
        "repos.user_repo",
        "repos.group_repo",
        "repos.member_repo",
        "mgmt.sync_group",
      ]

      def call(username, params)
        username = step validate_name(username)
        params = step validate_params(params)
        step register(username, params)
      end

      private def validate_params(params)
        validated_params = {
          **params.slice(:display_name, :email),
          deleted: false,
          deleted_at: nil,
        }

        if params.key?(:primary_group)
          validated_params[:primary_group] = get_group(params[:primary_group])
            .value_or { |failure| return Failure(failure) }
        end
        if params.key?(:groups)
          validated_params[:groups] =
            params[:groups].map do |groupname|
              get_group(groupname).value_or do |failure|
                return Failure(failure)
              end
            end
        end

        Success(validated_params)
      end

      def register(username, params)
        user_repo.transaction do
          user = user_repo.set(username, **params)

          if params.key?(:primary_group)
            member_repo.set_primary_group_for_user(user, params[:primary_group])
          end

          if params.key?(:groups)
            member_repo.set_groups_for_user(user, params[:groups])
          end
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
