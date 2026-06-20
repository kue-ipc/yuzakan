# frozen_string_literal: true

# Groupレポジトリからの解除
module Yuzakan
  module Management
    class UnregisterGroup < Yuzakan::Operation
      include Deps[
        "repos.group_repo",
        "repos.managed_group_repo",
      ]

      def call(groupname, time: Time.now)
        groupname = step validate_name(groupname)
        step unregister(groupname, time:)
      end

      def unregister(groupname, time: Time.now)
        group = group_repo.get(groupname)
        return Success(nil) if group.nil?

        group_repo.transaction do
          management_groups.clear_for_group(group)
          if group.deleted_at
            Success(group_repo.put!(groupname, synced_at: time))
          else
            Success(group_repo.put!(groupname, deleted_at: time, synced_at: time))
          end
        end
      end
    end
  end
end
