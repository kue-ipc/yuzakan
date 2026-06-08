# frozen_string_literal: true

module Yuzakan
  module Services
    class DeleteUser < Yuzakan::ServiceOperation
      category :user

      def call(username, services = nil)
        username = step validate_name(username)
        services = step get_services(services, method: :user_delete)

        services.to_h do |service|
          adapter = step get_adapter(service)
          userdata = adapter.delete_user(username)
          result =
            if userdata
              cache_delete(service) # delete list
              cache_delete(service, username)
              step convert_data(service, userdata)
            end
          [service.name, result]
        end.compact
      end
    end
  end
end
