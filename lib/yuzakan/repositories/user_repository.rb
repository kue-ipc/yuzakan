class UserRepository < Hanami::Repository
  associations do
    has_many :members
    has_many :groups, through: :members
    has_many :activities
  end

  def by_name(name)
    users.where(name: name)
  end

  def find_by_name(name)
    by_name(name).one
  end

  def find_by_name_or_sync(name)
    find_by_name(name) || sync(name)
  end

  def offset(offset)
    users.offset(offset)
  end

  def count(_)
    users.count
  end
end
