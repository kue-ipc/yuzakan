# frozen_string_literal: true

class ProviderTextParamRepository < Hanami::Repository
  associations do
    belongs_to :provider
  end

  def find_by_provider_and_name(data)
    provider_text_params
      .where(provider_id: data[:provider_id] || data[:provider].id)
      .where(name: data[:name])
      .one
  end

  def create_or_update(data)
    entry = find_by_provider_and_name(data)
    if data[:encrypted]
      result = Encrypt.new(max: 0).call(data: data[:value])
      data = data.merge(value: result.encrypted)
    end

    if entry
      update(entry.id, data)
    else
      create(data)
    end
  end
end
