# frozen_string_literal: true

class ProviderBooleanParamRepository < Hanami::Repository
  associations do
    belongs_to :provider
  end

  def find_by_provider_and_name(provider:, name:)
    provider_boolean_params
      .where(provider_id: provider.id)
      .where(name: name)
      .one
  end

  def create_or_update(provider)
  end

end
