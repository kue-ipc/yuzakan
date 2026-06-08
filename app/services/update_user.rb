# frozen_string_literal: true

module Yuzakan
  module Services
    class UpdateUser < Yuzakan::ServiceOperation
      category :user

      def call(username, services = nil, **params)
        username = step validate_name(username)
        params.delete(:password) # do not update password here
        services = step get_services(services, method: :user_update)

        services.to_h do |service|
          adapter = step get_adapter(service)
          userdata = step map_data(service, params)
          new_userdata = adapter.user_update(username, userdata)
          result =
            if new_userdata
              new_params = step convert_data(service, new_userdata)
              cache_write(service, username) { new_params }
              new_params
            end
          [service.name, result]
        end.compact
      end
    end
  end
end
