# frozen_string_literal: true

module Yuzakan
  module Relations
    class Members < Yuzakan::DB::Relation
      schema :members, infer: true do
        associations do
          belongs_to :user
          belongs_to :group
        end
      end
    end
  end
end
