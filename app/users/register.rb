# frozen_string_literal: true

# Userレポジトリへの登録または更新
module Yuzakan
  module Users
    class Register < Yuzakan::Operation
      include Deps[
        "repos.user_repo",
        "repos.group_repo",
        "repos.member_repo",
        "groups.sync",
      ]

      def call(username, params)
        username = step validate_name(username)
        params = step validate(params)
        step register(username, params)
      end

      private def validate(params)
        Success({
          **params.slice(:display_name, :email),
          primary_group: step(get_group(params[:primary_group])),
          groups: parasm[:groups]&.map { |groupname| set(get_group(groupname)) },
        })
      end

      def register(username, params)
        data = {
          name: username,
          **params.slice(:display_name, :email),
          deleted: false,
          deleted_at: nil,
        }
        primary_group = get_group(params[:primary_group])
        groups = parasm[:groups]&.map { |groupname| get_group(groupname) }


        user_repo.get(username)
        user_id = @user_repository.find_by_name(username)&.id

        @user_repository.transaction do
          @user =
            if user_id
              @user_repository.update(user_id, data)
            else
              @user_repository.create(data)
            end

          if params[:primary_group]
            @member_repository.set_primary_group_for_user(@user,
                                                          get_group(params[:primary_group]))
          end

          if params[:groups]
            groups = [params[:primary_group], *params[:groups]].compact.uniq.map { |groupname| get_group(groupname) }
            @member_repository.set_groups_for_user(@user, groups)
          end
        end

        @user = @user_repository.find_with_groups(@user.id)
      end

      private def get_group(groupname)
        return Success(nil) unless groupname

        group = group_repo.get(groupname)
        return Success(group) if group

        # FIXME groups.syncが失敗した場合は？
        sync(groupname)
      end
    end
  end
end
