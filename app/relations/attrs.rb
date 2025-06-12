# frozen_string_literal: true

module Yuzakan
  module Relations
    class Attrs < Yuzakan::DB::Relation
      schema :attrs, infer: true do
        associations do
          has_many :mappings
          has_many :providers, throught: :mappings
        end
      end

      # always ordered by order and name
      dataset do
        order(:order, :name)
      end
    end
  end
end
