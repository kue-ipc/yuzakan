# frozen_string_literal: true

class ProviderIntegerParamRepository < Hanami::Repository
  associations do
    belongs_to :provider
  end

  def by_provider_and_name(provider_id:, name:)
    provider_integer_params
      .where(provider_id: provider_id)
      .where(name: name)
  end
end
