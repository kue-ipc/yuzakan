class LocalGroupRepository < Hanami::Repository
  associations do
    has_many :local_members
    has_many :local_users, through: :local_members
  end
end
