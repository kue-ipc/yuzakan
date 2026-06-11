# frozen_string_literal: true

module Yuzakan
  module Relations
    class ManagedUsers < Yuzakan::DB::Relation
      schema :managed_users, infer: true do
        associations do
          belongs_to :service
          belongs_to :user
        end
      end
    end
  end
end
