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

      def delete_by_user(group) = by_group(group).changeset(:delete).commit
      def delete_by_group(group) = by_group(group).changeset(:delete).commit

      def set_primary_group_for_user(user, primary_group)
        if primary_group.nil?
          by_user(user).where(primary: true)
            .changeset(:update, primary: false).commit
          return
        end

        members.transaction do
          by_user(user).where(primary: true).exclude(group_id: primary_group.id)
            .changeset(:update, primary: false).commit

          by_user_and_by_group(user, primary_group)
            .changeset(:update, primary: true).commit ||
            members.changeset(:create,
              user_id: user.id, group_id: primary_group.id, primary: true)
              .commit
        end
      end

      def set_groups_for_user(user, _groups)
        group_ids = group.map(&:id)
        members.transaction do
          by_user(user).where(primary: false)
            .exclude(group_id: groups_ids)
            .changeset(:delete).commit
          current_group_ids = by_user(user).pluck(:group_id)

          # TODO: 作成が一つ一つになる
          (group_ids - current_group_ids).each do |group_id|
            members.changeset(:create,
              user_id: user.id, group_id: group_id, primary: false)
              .commit
          end
        end
        by_user(user).where(primary: false).to_a
      end
    end
  end
end
