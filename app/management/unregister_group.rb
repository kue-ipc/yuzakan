# frozen_string_literal: true

# Groupレポジトリからの解除
module Yuzakan
  module Management
    class UnregisterGroup < Yuzakan::Operation
      include Deps[
        "repos.group_repo",
        "repos.managed_group_repo"
      ]

      def call(groupname)
        groupname = step validate_name(groupname)
        step unregister(groupname)
      end

      def unregister(groupname)
        group = group_repo.get(groupname)
        return Success(nil) if group.nil?
        return Success(group) if group.deleted_at

        group_repo.transaction do
          management_groups.delete_by_group(group)
          Success(group_repo.set(groupname, deleted_at: Time.now))
        end
      end
    end
  end
end
