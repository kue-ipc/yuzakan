# frozen_string_literal: true

class UserRepository < Hanami::Repository
  associations do
    belongs_to :role
  end

  def find_with_role(id)
    aggregate(:role).where(id: id).map_to(User).one
  end

  def by_name(name)
    users.where(name: name).one
  end

  def auth(name, password)
    providers = ProviderRepository.new.operational_all(:auth)
    result = providers.each.each do |provider|
      res = provider.adapter.new(provider.params).auth(name, password)
      break res if res
    end


    if result
      display_name = result[:display_name] || result[:name]
      user = by_name(name)
      if user
        if user.display_name != display_name
          update(user.id, display_name: display_name)
        end
        if user.email != result[:email]
          update(user.id, email: result[:email])
        end
        find(user.id)
      else
        create(name: name, display_name: display_name, email: result[:email])
      end
    else
      nil
    end
  end
end
