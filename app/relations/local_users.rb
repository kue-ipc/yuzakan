# frozen_string_literal: true

module Yuzakan
  module Relations
    class LocalUsers < Yuzakan::DB::Relation
      schema :local_users, infer: true do
        associations do
          has_many :local_members
          has_many :local_groups, through: :local_members
        end
      end
    end
  end
end
