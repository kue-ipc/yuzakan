# frozen_string_literal: true

module Yuzakan
  module Relations
    class Providers < Yuzakan::DB::Relation
      schema :providers, infer: true do
        associations do
          has_many :attr_mappings
          has_many :attrs, throught: :attr_mappings
        end
      end

      # always ordered by order and name
      dataset do
        order(:order, :name)
      end
    end
  end
end
