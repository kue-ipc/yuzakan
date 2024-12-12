# frozen_string_literal: true

module Yuzakan
  module Relations
    class AttrMappings < Yuzakan::DB::Relation
      schema :attr_mappings, infer: true do
        associations do
          belongs_to :provider
          belongs_to :attr
        end
      end
    end
  end
end
