# frozen_string_literal: true

module Yuzakan
  module Services
    class SearchUser < Yuzakan::ServiceOperation
      category :user

      def call(query, services = nil)
        services = step get_services(services, method: :user_search)

        # No cache
        services.to_h do |service|
          adapter = step get_adapter(service)
          result = adapter.user_search(query)
          [service.name, result]
        end.compact
      end
    end
  end
end
