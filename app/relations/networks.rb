# frozen_string_literal: true

module Yuzakan
  module Relations
    class Networks < Yuzakan::DB::Relation
      schema :networks, infer: true

      # always ordered by address
      dataset do
        order(:address)
      end
    end
  end
end
