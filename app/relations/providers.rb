# frozen_string_literal: true

module Yuzakan
  module Relations
    class Providers < Yuzakan::DB::Relation
      schema :providers, infer: true do
        associations do
          has_many :adapter_params
          has_many :attr_mappings
          has_many :attrs, throught: :attr_mappings
        end
      end
    end
  end
end
