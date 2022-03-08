class AttrRepository < Hanami::Repository
  associations do
    has_many :attr_mappings
    has_many :providers, throught: :attr_mappings
  end

  private def by_name(name)
    attrs.where(name: name)
  end

  private def by_label(label)
    attrs.where(label: label)
  end

  private def by_order(order)
    attrs.where(order: order)
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

  def exist_by_order?(order)
    by_order(order).exist?
  end

  def ordered_all
    attrs.order(:order).to_a
  end

  def last_order
    attrs.order(:order).last&.fetch(:order).to_i
  end

  def ordered_all_with_mappings
    aggregate(attr_mappings: :provider).order(:order).map_to(Attr).to_a
  end

  def find_with_mappings(id)
    aggregate(attr_mappings: :provider).where(id: id).map_to(Attr).one
  end

  def find_with_mappings_by_name(name)
    aggregate(attr_mappings: :provider).where(name: name).map_to(Attr).one
  end

  def create_with_mappings(data)
    assoc(:attr_mappings).create(data)
  end

  def add_mapping(attr, data)
    assoc(:attr_mappings, attr).add(data)
  end

  private def mapping_by_provider_id(attr, provider_id)
    assoc(:attr_mappings, attr).where(provider_id: provider_id)
  end

  def delete_mapping_by_provider_id(attr, provider_id)
    mapping_by_provider_id(attr, provider_id).delete
  end

  def find_mapping_by_provider_id(attr, provider_id)
    mapping_by_provider_id(attr, provider_id).to_a.first
  end

end
