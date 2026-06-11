# frozen_string_literal: true

module Yuzakan
  module Services
    class CreateUser < Yuzakan::ServiceOperation
      category :user

      def call(service, username, password = nil, **params)
        return unless can_call?(service, :user_create)

        username = step validate_name(username)
        password = step validate_password(password) if password
        adapter = step get_adapter(service)
        userdata = step map_data(service, params)
        new_userdata = adapter.user_create(username, userdata, password:)
        return unless new_userdata

        cache_delete(service) # delete list
        new_params = step convert_data(service, new_userdata)
        cache_write(service, username) { new_params }
        new_params
      end
    end
  end
end
