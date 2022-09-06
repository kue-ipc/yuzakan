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
    find_by_groupname(groupname) || create({groupname: groupname, display_name: groupname})
  end
end
