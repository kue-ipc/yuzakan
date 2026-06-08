# frozen_string_literal: true

module Yuzakan
  module Services
    class ListGroup < Yuzakan::ServiceOperation
      category :group

      def call(services = nil)
        services = step get_services(services, method: :group_list)

        services.to_h do |service|
          result = cache_fetch(service) do
            adapter = step get_adapter(service)
            adapter.group_list
          end
          [service.name, result]
        end.compact
      end
    end
  end
end
