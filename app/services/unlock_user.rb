# frozen_string_literal: true

module Yuzakan
  module Services
    class UnlockUser < Yuzakan::ServiceOperation
      include Deps["services.list_user"]

      category :user

      def call(service, username, password = nil)
        return unless can_call?(service, :user_unlock)

        username = step validate_name(username)
        list = step list_user.call(service)
        return unless list.include?(username)

        password = step validate_password(password) if password
        adapter = step get_adapter(service)
        adapter.user_unlock(username, password:).tap do |result|
          cache_delete(service, username) if result
        end
      end
    end
  end
end
