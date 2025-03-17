# frozen_string_literal: true

module Yuzakan
  module Repos
    class MemberRepo < Yuzakan::DB::Repo
      private def by_user_id(id) = members.by_user_id(id)
      private def by_user(user) = by_user_id(user.id)
      private def by_group_id(id) = members.by_group_id(id)
      private def by_group(group) = by_group_id(group.id)
      private def by_user_id_and_by_group_id(user_id, group_id)
        members.by_user_id_and_by_group_id(user_id, group_id)
      end
      private def by_user_and_by_group(user, group)
        by_user_id_and_by_group_id(user.id, group.id)
      end

      def delete_by_user(user) = by_user(user).changeset(:delete).commit
      def delete_by_group(group) = by_group(group).changeset(:delete).commit

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
