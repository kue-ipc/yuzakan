# frozen_string_literal: true

class AttrTypeRepository < Hanami::Repository
  associations do
    has_many :provider_attr_mappings
  end

  def all_with_mappings
    aggregate(:provider_attr_mappings)
  end
end
