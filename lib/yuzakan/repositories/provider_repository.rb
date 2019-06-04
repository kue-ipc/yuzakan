# frozen_string_literal: true

class ProviderRepository < Hanami::Repository
  def self.params
    %i[
      provider_string_params
      provider_integer_params
      provider_boolean_params
      provider_secret_params
    ]
  end

  associations do
    ProviderRepository.params.each do |param|
      has_many param
    end
  end

  def authenticatables
    providers
      .where(authenticatable: true)
      .order { order.asc }
  end

  def authenticatables_with_params
    aggregate(*ProviderRepository.params)
      .where(authenticatable: true)
      .order { order.asc }
      .map_to(Provider)
  end

  def last_order
    providers.order { order.desc }.first
  end

end
