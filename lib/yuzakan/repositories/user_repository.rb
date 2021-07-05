class UserRepository < Hanami::Repository
  associations do
    has_many :members
    has_many :groups, through: :members
    has_many :activities
  end

  def by_name(name)
    users.where(name: name)
  end

  def offset(offset)
    users.offset(offset)
  end

  def count(_)
    users.count
  end

  def auth(name, password)
    providers = ProviderRepository.new.operational_all_with_adapter(:auth)
    result = nil
    providers.each do |provider|
      result = provider.adapter.auth(name, password)
      break if result
    end

    if result
      display_name = result[:display_name] || result[:name]
      user = by_name(name)
      if user
        if user.display_name != display_name
          update(user.id, display_name: display_name)
        end
        update(user.id, email: result[:email]) if user.email != result[:email]
        find(user.id)
      else
        create(name: name, display_name: display_name, email: result[:email])
      end
    end
  end

  def sync(name)
    providers = ProviderRepository.new.operational_all_with_adapter(:read)
    result = nil
    providers.each do |provider|
      result = provider.adapter.read(name)
      break if result
    end

    return unless result

    display_name = result[:display_name] || result[:name]
    email = result[:email]
    user = by_name(name).one

    unless user
      return create(name: name, display_name: display_name, email: email)
    end

    if user.display_name != display_name || user.email != email
      return update(user.id, {display_name: display_name, email: email})
    end

    user
  end
end
