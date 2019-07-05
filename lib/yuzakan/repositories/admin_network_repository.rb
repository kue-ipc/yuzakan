class AdminNetworkRepository < Hanami::Repository
  def count
    admin_networks.count
  end

  def by_family(family)
    admin_networksn.where(family: family)
  end
end
