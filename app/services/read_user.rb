# frozen_string_literal: true

module Yuzakan
  module Services
    class ReadUser < Yuzakan::ServiceOperation
      category :user

      def call(username, services = nil)
        username = step validate_name(username)
        services = step get_services(services, method: :user_read)

        services.to_h do |service|
          result =
            cache_fetch(service, username) do
              adapter = step get_adapter(service)
              userdata = adapter.user_read(username)
              step convert_data(service, userdata)
            end
          [service, result]
        end.compact
      end
    end
  end
end
