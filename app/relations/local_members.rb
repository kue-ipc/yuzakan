# frozen_string_literal: true

module Yuzakan
  module Relations
    class LocalMembers < Yuzakan::DB::Relation
      schema :local_members, infer: true do
        associations do
          belongs_to :local_user
          belongs_to :local_group
        end
      end
    end
  end
end
