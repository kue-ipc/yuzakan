# frozen_string_literal: true

module Yuzakan
  module Services
    class AuthUser < Yuzakan::ServiceOperation
      category :user

      def call(service, username, password)
        return unless can_call?(service, :user_auth)

        username = step validate_name(username)
        password = step validate_password(password)
        adapter = step get_adapter(service)
        adapter.user_auth(username, password)
      end
    end
  end
end
