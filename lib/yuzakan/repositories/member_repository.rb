# frozen_string_literal: true

class MemberRepository < Hanami::Repository
  associations do
    belongs_to :user
    belongs_to :group
  end

  def find_primary_of_user(user)
    members.where(user_id: user.id, primary: true).one
  end

  def find_of_user_group(user, group)
    members.where(user_id: user.id, group_id: group.id).one
  end

  def all_of_user(user)
    members.where(user_id: user.id).to_a
  end

  def clear_of_user(user)
    members.where(user_id: user.id).delete
  end

  def set_primary_group_for_user(user, group)
    primary_member = find_primary_of_user(user)

    # 既存が設定済みの場合はそのまま終了する。
    return primary_member if primary_member&.group_id == group&.id

    # 既存を格下げ
    update(primary_member.id, {primary: false}) if primary_member

    # プライマリーグループがない場合はそのまま終了
    return if group.nil?

    # 既存がある場合は更新、無ければ作成
    member = find_of_user_group(user, group)
    if member
      update(primary_member.id, {primary: true})
    else
      create({user_id: user.id, group_id: group.id, primary: true})
    end
  end

  def set_groups_for_user(user, groups)
    remains = all_of_user(user).to_h { |member| [member.group_id, member] }
    members = []
    groups.each do |group|
      members << (remains.delete(group.id) || create({user_id: user.id, group_id: group.id}))
    end
    remains.each { |member| delete(member.id) }
    members
  end
end
