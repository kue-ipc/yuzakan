class UserRepository < Hanami::Repository
  associations do
    has_many :members
    has_many :groups, through: :members
    has_many :activities
  end

  def by_name(name)
    users.where(name: name)
  end

  def find_by_name_or_sync(name)
    by_name(name).one || sync(name)
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
      result = provider.auth(name, password)
      break if result
    end

    return unless result

    display_name = result[:display_name] || result[:name]
    user = by_name(name)
    if user
      update(user.id, display_name: display_name) if user.display_name != display_name
      update(user.id, email: result[:email]) if user.email != result[:email]
      find(user.id)
    else
      create(name: name, display_name: display_name, email: result[:email])
    end
  end

  def sync(name)
    providers = ProviderRepository.new.operational_all_with_adapter(:read)
    result = nil
    providers.each do |provider|
      result = provider.read(name)
      break if result
    end

    return unless result

    display_name = result[:display_name] || result[:name]
    email = result[:email]
    user = by_name(name).one

    return create(name: name, display_name: display_name, email: email) unless user

    if user.display_name != display_name || user.email != email
      return update(user.id, {display_name: display_name, email: email})
    end

    user
  end
end
