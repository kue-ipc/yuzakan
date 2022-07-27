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

  def find_by_username_or_sync(username)
    find_by_username(username) || sync(username)
  end

  def offset(offset)
    users.offset(offset)
  end

  def count(_)
    users.count
  end
end
