class AttrRepository < Hanami::Repository
  associations do
    has_many :attr_mappings
  end

  private def by_name(name)
    attrs.where(name: name)
  end

  private def by_label(label)
    attrs.where(label: label)
  end

  def find_by_name(name)
    by_name(name).one
  end

  def exist_by_name?(name)
    by_name(name).exist?
  end

  def exist_by_label?(label)
    by_label(label).exist?
  end

  def ordered_all
    attrs.order(:order).to_a
  end

  def last_order
    attrs.order(:order).last&.fetch(:order).to_i
  end

  def ordered_all_with_mappings
    aggregate(:attr_mappings).order(:order).map_to(Attr).to_a
  end

  def find_with_mappings(id)
    aggregate(:attr_mappings).where(id: id).map_to(Attr).one
  end

  def create_with_mappings(data)
    assoc(:attr_mappings).create(data)
  end

  def add_mapping(attr, data)
    assoc(:attr_mappings, attr).add(data)
  end

  def delete_mapping_by_provider_id(attr, provider_id)
    assoc(:attr_mappings, attr).where(provider_id: provider_id).delete
  end

  def update_mapping_by_provider_id(attr, provider_id, data)
    assoc(:attr_mappings, attr).where(provider_id: provider_id).update(data)
  end

  # def update_mapping(attr, id, data)
  #   assoc(:attr_mappings, attr).update(id, data)
  # end

  # def mapping_by_provider_id(attr, provider_id)
  #   assoc(:attr_mappings, attr).where(provider_id: provider_id)
  # end

  # def mapping_by_provider(attr, provider)
  #   mapping_by_provider_id(attr, provider.id)
  # end
end
