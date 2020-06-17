class ProviderAttrMappingRepository < Hanami::Repository
  def find_by_provider_attr_type(provider_id, attr_type_id)
    provider_attr_mappings.where(provider_id: provider_id)
    .where(attr_type_id: attr_type_id)
    .one
  end
end
