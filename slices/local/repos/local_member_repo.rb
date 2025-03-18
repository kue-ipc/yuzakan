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
    end
  end
end
