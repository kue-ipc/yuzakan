# frozen_string_literal: true

module Yuzakan
  module Relations
    class Groups < Yuzakan::DB::Relation
      schema :groups, infer: true do
        associations do
          has_many :members
          has_many :users, through: :members
        end
      end
    end
  end
end
