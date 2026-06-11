# frozen_string_literal: true

module Yuzakan
  module Services
    class UpdateUser < Yuzakan::ServiceOperation
      category :user

      def call(service, username, **params)
        return unless can_call?(service, :user_update)

        username = step validate_name(username)
        adapter = step get_adapter(service)
        userdata = step map_data(service, params)
        new_userdata = adapter.user_update(username, userdata)
        return unless new_userdata

        new_params = step convert_data(service, new_userdata)
        cache_write(service, username) { new_params }
        new_params
      end
    end
  end
end
