# frozen_string_literal: true

module Yuzakan
  module Relations
    class AdapterParams < Yuzakan::DB::Relation
      schema :adapter_params, infer: true do
        associations do
          belongs_to :provider
        end
      end
    end
  end
end
