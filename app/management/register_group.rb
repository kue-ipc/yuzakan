# frozen_string_literal: true

# Groupレポジトリへの登録または更新
module Yuzakan
  module Management
    class RegisterGroup < Yuzakan::Operation
      include Deps[
        "repos.group_repo",
        "repos.managed_group_repo",
      ]

      def call(groupname, params)
        groupname = step validate_name(groupname)
        step register(groupname, params)
      end

      private def register(groupname, params)
        group_repo.transaction do
          group_params = params.slice(:label, :unmanageable, :attrs)
          group = group_repo.set(groupname, **group_params)
          managed_group_repo.set_services_for_group(group, params[:services]) if params.key?(:services)
        end

        Success(group_repo.get_with_associations(groupname))
      end
    end
  end
end
