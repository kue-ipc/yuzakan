# frozen_string_literal: true

class ProviderBooleanParamRepository < Hanami::Repository
  associations do
    belongs_to :provider
  end

  def by_provider_and_name(provider_id:, name:)
    provider_boolean_params
      .where(provider_id: provider_id)
      .where(name: name)
  end
end
