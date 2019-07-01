# frozen_string_literal: true

class ProviderStringParamRepository < Hanami::Repository
  associations do
    belongs_to :provider
  end

  def by_provider_and_name(provider_id:, name:)
    provider_string_params
      .where(provider_id: provider_id)
      .where(name: name)
  end
end
