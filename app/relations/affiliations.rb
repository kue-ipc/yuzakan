# frozen_string_literal: true

module Yuzakan
  module Relations
    class Affiliations < Yuzakan::DB::Relation
      schema :affiliations, infer: true do
        associations do
          has_many :users
          has_many :groups
        end
      end
    end
  end
end
