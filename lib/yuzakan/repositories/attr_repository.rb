class AttrRepository < Hanami::Repository
  associations do
    has_many :attr_mappings
  end

  def by_name(name)
    attrs.where(name: name)
  end

  def by_label(label)
    attrs.where(label: label)
  end

  def all_no_hidden
    attrs.where(hidden: false).to_a
  end

  def ordered_all
    attrs.order(:order).to_a
  end

  def ordered_all_with_mappings
    aggregate(:attr_mappings)
      .order(:order)
      .map_to(Attr)
  end
  alias all_with_mappings ordered_all_with_mappings

  def last_order
    attrs.order(:order).last&.fetch(:order).to_i
  end

  def add_mapping(attr, data)
    assoc(:attr_mappings, attr).add(data)
  end

  def remove_mapping(attr, id)
    assoc(:attr_mappings, attr).remove(id)
  end

  def create_with_mappings(data)
    assoc(:attr_mappings).create(data)
  end
end
