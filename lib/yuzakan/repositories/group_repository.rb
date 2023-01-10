# frozen_string_literal: true

class GroupRepository < Hanami::Repository
  associations do
    has_many :members
    has_many :users, through: :members
  end

  def by_groupname(groupname)
    groups.where(groupname: groupname)
  end

  def find_by_groupname(groupname)
    by_groupname(groupname).one
  end

  def find_or_create_by_groupname(groupname)
    find_by_groupname(groupname) || create({groupname: groupname})
  end

  def add_user(group, user)
    member = member_for(group, user).one
    return if member

    assoc(:members, group).add(user_id: user.id)
  end

  def remove_user(group, user)
    member = member_for(group, user).one
    return unless member

    assoc(:members, group).remove(member.id)
  end

  private def member_for(group, user)
    assoc(:members, group).where(user_id: user.id)
  end
end
