# frozen_string_literal: true

class UserRepository < Hanami::Repository
  associations do
    has_many :members
    has_many :groups, through: :members
  end

  def by_name(name)
    users.where(name: name).one
  end

  def auth(name, password)
    providers = ProviderRepository.new.operational_all_with_params(:auth)
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
