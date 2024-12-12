# frozen_string_literal: true

module Yuzakan
  module Repos
    class MemberRepo < Yuzakan::DB::Repo
      def find_of_user_group(user, group)
        members.where(user_id: user.id, group_id: group.id).one
      end

      private def primary_of_user(user)
        members.where(user_id: user.id, primary: true)
      end

      private def of_user(user)
        members.where(user_id: user.id)
      end

      def clear_of_user(user)
        of_user(user).delete
      end

      def set_primary_group_for_user(user, group)
        primary = nil
        primary_of_user(user).each do |member|
          if member.group_id == group&.id
            primary = member
          else
            # 既存を格下げ
            update(member.id, {primary: false})
          end
        end

        # 既存が設定済みの場合は終了。
        return primary if primary

        # プライマリーグループがない場合は終了。
        return if group.nil?

        # 既存がある場合は更新、無ければ作成
        member = find_of_user_group(user, group)
        if member
          update(member.id, {primary: true})
        else
          create({user_id: user.id, group_id: group.id, primary: true})
        end
      end

      def set_groups_for_user(user, groups)
        remains = of_user(user).to_a.to_h { |member| [member.group_id, member] }
        members = groups.map do |group|
          remains.delete(group.id) || create({user_id: user.id, group_id: group.id})
        end
        remains.each_value { |member| delete(member.id) }
        members
      end
    end
  end
end
