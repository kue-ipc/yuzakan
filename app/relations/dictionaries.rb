# frozen_string_literal: true

module Yuzakan
  module Relations
    class Dictionaries < Yuzakan::DB::Relation
      schema :dictionaries, infer: true do
        associations do
          has_many :terms
        end
      end
    end
  end
end
