class GroupRepository < Hanami::Repository
  associations do
    has_many :members
    has_many :users, through: :members
  end

  def by_name(name)
    groups.where(name: name)
  end

  def find_by_name(name)
    by_name(name).one
  end
end
