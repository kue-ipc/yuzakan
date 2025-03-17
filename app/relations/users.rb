# frozen_string_literal: true

module Yuzakan
  module Relations
    class Users < Yuzakan::DB::Relation
      schema :users, infer: true do
        associations do
          belongs_to :group
          has_many :members
          has_many :groups, as: :member_groups, through: :members
        end
      end

      # always ordered by name
      dataset do
        order(:name)
      end
    end
  end
end
