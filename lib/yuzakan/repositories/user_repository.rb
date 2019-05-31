# frozen_string_literal: true

class UserRepository < Hanami::Repository
  associations do
    belongs_to :role
  end

  def by_name(name)
    users.where(name: name).one
  end

  def auth(name, password)
    providers = ProviderRepository.new.authenticatables_with_params
    result = providers.each.any? do |provider|
      provider.adapter.new(provider.params).auth(name, password)
    end

    if result
      by_name(name) || create(name: name)
    else
      nil
    end
  end
end
