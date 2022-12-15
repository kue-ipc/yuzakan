class UserRepository < Hanami::Repository
  associations do
    bleongs_to :primary_group
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
    aggregate(:groups).where(id: id).map_to(User).one
  end

  def find_with_primary_group_and_groups(id)
    aggregate(:primary_group, :groups).where(id: id).map_to(User).one
  end

  def find_with_primary_group_and_groups_by_username(username)
    aggregate(:primary_group, :groups).where(username: username).map_to(User).one
  end

  def set_primary_group(user, group)
    return unless user.primary_group_id != group&.id

    update(user.id, primary_group_id: group&.id)
  end

  def add_group(user, group)
    member = member_for(user, group).one
    return if member

    assoc(:members, user).add(group_id: group.id)
  end

  def remove_group(user, group)
    member = member_for(user, group).one
    return unless member

    assoc(:members, user).remove(member.id)
  end

  private def member_for(user, group)
    assoc(:members, user).where(group_id: group.id)
  end
end
