# frozen_string_literal: true

module Yuzakan
  module Repos
    class MemberRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = members.to_a
      def find(id) = members.by_pk(id).one
      def first = members.first
      def last = members.last
      def clear = members.delete

      # other interfaces
      private def by_user(user) = members.by_user_id(user.id)
      private def by_group(group) = members.by_group_id(group.id)
      private def by_user_and_group(user, group)
        members.by_user_id(user.id).by_group_id(group.id)
      end

      def delete_by_user(user) = by_user(user).command(:delete).call
      def delete_by_group(group) = by_group(group).command(:delete).call

      def create_by_user_and_group(user, group) = create(user_id: user.id, group_id: group.id)
      def delete_by_user_and_group(user, group) = by_user_and_group(user, group).command(:delete).call
      def find_by_user_and_group(user, group) = by_user_and_group(user, group).one
      def exist_by_user_and_group?(user, group) = by_user_and_group(user, group).exist?

      # TODO: メソッド名を変えたほうがいいのでは？
      def set_groups_for_user(user, groups)
        group_ids = groups.map(&:id)
        members.transaction do
          by_user(user).exclude(group_id: group_ids).changeset(:delete).commit
          current_group_ids = by_user(user).pluck(:group_id)
          (group_ids - current_group_ids).each do |group_id|
            members.changeset(:create, user_id: user.id, group_id: group_id)
              .commit
          end
        end
        by_user(user).to_a
      end
    end
  end
end
