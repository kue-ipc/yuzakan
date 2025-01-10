# frozen_string_literal: true

module Yuzakan
  module Relations
    class LocalGroups < Yuzakan::DB::Relation
      schema :local_groups, infer: true do
        associations do
          has_many :local_members
          has_many :local_users, through: :members
        end
      end
    end
  end
end
