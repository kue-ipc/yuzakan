# frozen_string_literal: true

module Yuzakan
  module Services
    class DeleteUser < Yuzakan::ServiceOperation
      category :user

      def call(service, username)
        return unless can_call?(service, :user_delete)

        username = step validate_name(username)
        adapter = step get_adapter(service)
        userdata = adapter.delete_user(username)
        return unless userdata

        cache_delete(service) # delete list
        cache_delete(service, username)
        step convert_data(service, userdata)
      end
    end
  end
end
