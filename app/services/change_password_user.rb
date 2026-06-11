# frozen_string_literal: true

module Yuzakan
  module Services
    class ChangePasswordUser < Yuzakan::ServiceOperation
      include Deps["services.list_user"]

      category :user

      def call(service, username, password)
        return unless can_call?(service, :user_change_password)

        username = step validate_name(username)
        list = step list_user.call(service)
        return unless list.include?(username)

        password = step validate_password(password)
        adapter = step get_adapter(service)
        adapter.user_change_password(username, password)
      end
    end
  end
end
