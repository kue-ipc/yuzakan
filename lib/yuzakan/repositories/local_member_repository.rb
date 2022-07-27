class LocalMemberRepository < Hanami::Repository
  associations do
    belongs_to :local_user
    belongs_to :local_group
  end
end
