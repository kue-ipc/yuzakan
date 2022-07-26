class NetworkRepository < Hanami::Repository
  private :create, :update, :delete

  def create_by_address(address, data)
    create({address: address, **data})
  end

  def update_by_address(address, data)
    update(find_by_address(address).id, data)
  end

  def delete_by_address(address)
    delete(find_by_address(address).id)
  end

  def find_by_address(address)
    by_address(address).one
  end

  def by_address(address)
    networsk.by_address
  end
end
