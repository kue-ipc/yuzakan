# frozen_string_literal: true

module Yuzakan
  module Services
    class SearchUser < Yuzakan::ServiceOperation
      category :user

      def call(service, query)
        return unless can_call?(service, :user_search)

        # No cache
        adapter = step get_adapter(service)
        adapter.user_search(query)
      end
    end
  end
end
