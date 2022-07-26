require 'ipaddr'

class NetworkRepository < Hanami::Repository
  private :create, :update, :delete

  def create_by_address(address, data)
    create({**data, address: normalize_address(address)})
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
    networsk.by_address(normalize_address(address))
  end

  private def normalize_address(address)
    ipaddr = IPAddr.new(address)
    prefix = ipaddr.prefix
    if (prefix == 32 && ipaddr.ipv4?) ||
      (prefix == 128 && ipaddr.ipv6?)
      ipaddr.to_s
    else
      "#{ipaddr}/#{ipaddr.prefix}"
    end
  end
end
