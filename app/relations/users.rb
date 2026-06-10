# frozen_string_literal: true

module Yuzakan
  module Relations
    class Users < Yuzakan::DB::Relation
      schema :users, infer: true do
        associations do
          belongs_to :affiliation
          belongs_to :group
          has_many :members
          has_many :groups, as: :member_groups, through: :members
          has_many :managed_users
          has_many :services, through: :managed_users
        end
      end

      use :pagination
      per_page DEFAULT_PER_PAGE

      # always ordered by name
      dataset do
        order(:name)
      end
    end
  end
end
