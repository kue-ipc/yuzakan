# frozen_string_literal: true

module Yuzakan
  module Services
    class SearchGroup < Yuzakan::ServiceOperation
      category :group

      def call(query, services = nil)
        services = step get_services(services, method: :group_search)

        # No cache
        services.to_h do |service|
          adapter = step get_adapter(service)
          result = adapter.group_search(query)
          [service.name, result]
        end.compact
      end
    end
  end
end
