# frozen_string_literal: true

class ProviderParamRepository < Hanami::Repository
  associations do
    belongs_to :provider
  end

  def find_by_provider_and_name(data)
    provider_params
      .where(provider_id: data[:provider_id] || data[:provider].id)
      .where(name: data[:name])
      .one
  end

  def create_or_update(data)
    entry = find_by_provider_and_name(data)
    if entry
      update(entry.id, data)
    else
      create(data)
    end
  end

  def all_by_provider(provider)
    all_by_provider_id(provider.id)
  end

  def all_by_provider_id(provider_id)
    provider_params
      .where(provider_id: provider_id)
      .to_a
  end
end
