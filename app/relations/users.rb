# frozen_string_literal: true

module Yuzakan
  module Relations
    class Users < Yuzakan::DB::Relation
      schema :users, infer: true do
        associations do
          has_many :members
          has_many :groups, through: :members
        end
      end
    end
  end
end
