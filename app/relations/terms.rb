# frozen_string_literal: true

module Yuzakan
  module Relations
    class Terms < Yuzakan::DB::Relation
      schema :terms, infer: true do
        associations do
          belongs_to :dictionary
        end
      end
    end
  end
end
