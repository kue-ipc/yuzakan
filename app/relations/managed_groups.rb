# frozen_string_literal: true

module Yuzakan
  module Relations
    class ManagedGroups < Yuzakan::DB::Relation
      schema :managed_groups, infer: true do
        associations do
          belongs_to :service
          belongs_to :group
        end
      end
    end
  end
end
