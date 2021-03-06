class AttrRepository < Hanami::Repository
  associations do
    has_many :attr_mappings
  end

  def all_with_mappings
    aggregate(:attr_mappings)
  end

  def last_order
    attrs.order { order.desc }.first
  end
end
