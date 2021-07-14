class AttrRepository < Hanami::Repository
  associations do
    has_many :attr_mappings
  end

  def all_with_mappings
    aggregate(:attr_mappings)
      .map_to(Attr)
  end

  def last_order
    attrs.order { order.desc }.first
  end
end
