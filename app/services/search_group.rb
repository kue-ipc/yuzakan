# frozen_string_literal: true

module Yuzakan
  module Services
    class SearchGroup < Yuzakan::ServiceOperation
      category :group

      def call(service, query)
        return unless can_call?(service, :group_search)

        # No cache
        adapter = step get_adapter(service)
        adapter.group_search(query)
      end
    end
  end
end
