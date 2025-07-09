# frozen_string_literal: true

module Yuzakan
  module Relations
    class Services < Yuzakan::DB::Relation
      schema :services, infer: true do
        associations do
          has_many :mappings
          has_many :attrs, throught: :mappings
        end
      end

      # always ordered by order and name
      dataset do
        order(:order, :name)
      end
    end
  end
end
