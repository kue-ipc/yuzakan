class ProviderBooleanParamRepository < Hanami::Repository
  associations do
    belongs_to :provider
  end

  def find_by_provider_and_name(data)
    provider_boolean_params
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
end
