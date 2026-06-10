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

      def for_users(users)
        where(user_id: users.map(&:id))
      end
    end
  end
end
