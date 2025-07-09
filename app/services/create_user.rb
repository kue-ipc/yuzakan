# frozen_string_literal: true

module Yuzakan
  module Services
    class CreateUser < Yuzakan::ServiceOperation
      category :user

      def call(username, services = nil, **params)
        username = step validate_name(username)
        services = step get_services(services, method: :user_create)

        password = params.delete(:password)

        # TODO: 途中で失敗した場合の処理
        services.to_h do |service|
          adapter = step get_adapter(service)
          userdata = step map_data(service, params)
          new_userdata = adapter.user_create(username, userdata, password:)
          result =
            if new_userdata
              new_params = step convert_data(service, new_userdata)
              cache_delete(service)
              cache_write(service, username) { new_params }
              new_params
            end
          [service.name, result]
        end
      end
    end
  end
end
