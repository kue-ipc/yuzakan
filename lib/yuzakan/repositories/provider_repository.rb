# frozen_string_literal: true

class ProviderRepository < Hanami::Repository
  PARAMS = [
    :provider_string_params,
    :provider_integer_params,
    :provider_boolean_params,
    :provider_secret_params,
  ]

  associations do
    PARAMS.each do |param|
      has_many param
    end
  end

  def authenticatables
    providers
      .where(authenticatable: true)
      .order { order.asc }
  end

  def authenticatables_with_params
    aggregate(*PARAMS)
      .where(authenticatable: true)
      .order { order.asc }
      .map_to(Provider)
  end

end
