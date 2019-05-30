# frozen_string_literal: true

class UserRepository < Hanami::Repository
  associations do
    belongs_to :role
  end

  def by_name(name)
    users.where(name: name).first
  end

  def auth(name, password)
    result = ProviderRepository.new.authenticatables.any? do |provider|
      provider.auth(name, password)
    end
    if result
      by_name(name) || create(name: name)
    end
    nil
  end
end
