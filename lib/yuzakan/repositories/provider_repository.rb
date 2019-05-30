# frozen_string_literal: true

class ProviderRepository < Hanami::Repository
  def authenticatables
    providers.where(authenticatable: true).order { order.asc }
  end
end
