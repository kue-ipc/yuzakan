class ProviderAttrMappingRepository < Hanami::Repository
  associations do
    belongs_to :attr_type
  end

  def find_by_provider_attr_type(provider_id, attr_type_id)
    provider_attr_mappings.where(provider_id: provider_id)
      .where(attr_type_id: attr_type_id)
      .one
  end

  def by_provider_with_attr_type(provider_id)
    aggregate(:attr_type)
      .where(provider_id: provider_id)
      .map_to(ProviderAttrMapping)
  end
end
