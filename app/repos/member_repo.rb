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

      # for associations
      private def for_user(user) = members.by_user_id(user.id)
      private def for_group(group) = members.by_group_id(group.id)
      private def for_user_and_group(user, group) = members.by_user_id_and_group_id(user.id, group.id)

      def all_for_user(user) = for_user(user).to_a
      def all_for_group(group) = for_group(group).to_a
      def clear_for_user(user) = for_user(user).command(:delete).call
      def clear_for_group(group) = for_group(group).command(:delete).call

      def create_for_user_and_group(user, group) = create(user_id: user.id, group_id: group.id)
      def delete_for_user_and_group(user, group) = for_user_and_group(user, group).command(:delete).call
      def find_for_user_and_group(user, group) = for_user_and_group(user, group).one
      def exist_for_user_and_group?(user, group) = for_user_and_group(user, group).exist?

      def set_groups_for_user(user, groups)
        group_ids = groups.map(&:id)
        members.transaction do
          for_user(user).exclude(group_id: group_ids).command(:delete).call
          current_group_ids = for_user(user).pluck(:group_id)
          groups.reject { |group| current_group_ids.include?(group.id) }.each do |group|
            create_for_user_and_group(user, group)
          end
        end
      end
    end
  end
end
