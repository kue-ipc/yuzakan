# frozen_string_literal: true

module Yuzakan
  module Relations
    class Groups < Yuzakan::DB::Relation
      schema :groups, infer: true do
        associations do
          belongs_to :affiliation
          has_many :users
          has_many :members
          has_many :users, as: :member_users, through: :members
        end
      end

      # always ordered by name
      dataset do
        order(:name)
      end
    end
  end
end
