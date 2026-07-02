# frozen_string_literal: true

module Local
  module Repos
    class LocalMemberRepo < Local::DB::Repo
      commands :create
      def all = local_members.to_a
      def first = local_members.first
      def last = local_members.last
      def clear = local_members.delete

      # id (pk)
      commands update: :by_pk, delete: :by_pk
      def ids = local_members.pluck(:id)
      private def by_id(id) = local_members.by_pk(id)
      def find(id) = by_id(id).one
      def exist?(id) = by_id(id).exist?

      # by_local_user_by_local_group
      private def by_local_user_and_local_group(user, group)
        local_members.by_local_user_id_and_local_group_id(user.id, group.id)
      end
      def find_by_local_user_and_local_group(user, group)
        by_local_user_and_local_group(user, group).one
      end

      def set_groups_for_user(user, groups)
        group_ids = groups.map(&:id)
        local_members.transaction do
          local_members.by_local_user_id(user.id).exclude(local_group_id: group_ids).command(:delete).call
          current_group_ids = local_members.by_local_user_id(user.id).pluck(:local_group_id)
          groups.reject { |group| current_group_ids.include?(group.id) }.each do |group|
            create(local_user_id: user.id, local_group_id: group.id)
          end
        end
      end
    end
  end
end
