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
    attrs.where(hidden: false).order(:order).to_a
  end

  def all
    attrs.order(:order).to_a
  end

  def all_with_mappings
    aggregate(:attr_mappings)
      .order(:order)
      .map_to(Attr)
  end

  def last_order
    attrs.order { order.desc }.first
  end

  def add_mapping(attr, data)
    assoc(:attr_mappings, attr).add(data)
  end

  def remove_mapping(attr, id)
    assoc(:attr_mappings, attr).remove(id)
  end
end
