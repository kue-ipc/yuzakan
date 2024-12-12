# frozen_string_literal: true

module Yuzakan
  module Relations
    class Networks < Yuzakan::DB::Relation
      schema :networks, infer: true
    end
  end
end
