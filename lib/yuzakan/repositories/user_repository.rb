# frozen_string_literal: true

class UserRepository < Hanami::Repository
  associations do
    has_many :members
    has_many :groups, through: :members
  end

  def by_username(username)
    users.where(username: username)
  end

  def find_by_username(username)
    by_username(username).one
  end

  def offset(offset)
    users.offset(offset)
  end

  def count(_)
    users.count
  end

  def find_with_groups(id)
    aggregate(:groups, members: :groups).where(id: id).map_to(User).one
  end

  def find_with_groups_by_username(username)
    aggregate(:groups, members: :groups).where(username: username).map_to(User).one
  end

  def set_primary_group(user, group)
    primary_member = assoc(:members, user).where(primary: true).one
    return primary_member if primary_member&.group_id == group.id

    member = assoc(:members, user).where(group_id: group.id).one

    assoc(:members, user).update(primary_member.id, primary: false) if primary_member

    if member
      assoc(:members, user).update(member.id, primary: true)
    else
      assoc(:members, user).add(group_id: group.id, primary: true)
    end
  end

  def add_group(user, group)
    member = assoc(:members, user).where(group_id: group.id).one
    return member if member

    assoc(:members, user).add(group_id: group.id)
  end

  def remove_group(user, group)
    member = assoc(:members, user).where(group_id: group.id).one
    return unless member

    assoc(:members, user).remove(member.id)
  end
end
