# frozen_string_literal: true

module Yuzakan
  module Relations
    class ProviderParams < Yuzakan::DB::Relation
      schema :provider_params, infer: true do
        associations do
          belongs_to :provider
        end
      end
    end
  end
end
