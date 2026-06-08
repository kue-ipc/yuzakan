# frozen_string_literal: true

module Yuzakan
  module Services
    class ListUser < Yuzakan::ServiceOperation
      category :user

      def call(services = nil)
        services = step get_services(services, method: :user_list)

        services.to_h do |service|
          result = cache_fetch(service) do
            adapter = step get_adapter(service)
            adapter.user_list
          end
          [service.name, result]
        end.compact
      end
    end
  end
end
