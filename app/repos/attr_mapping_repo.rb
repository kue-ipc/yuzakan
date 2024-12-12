# frozen_string_literal: true

class AttrMappingRepository < Hanami::Repository
  associations do
    belongs_to :provider
    belongs_to :attr
  end

  def find_by_provider_attr(provider_id, attr_id)
    attr_mappings.where(provider_id: provider_id)
      .where(attr_id: attr_id)
      .one
  end

  def by_provider_with_attr(provider_id)
    aggregate(:attr)
      .where(provider_id: provider_id)
      .map_to(AttrMapping)
  end
end
