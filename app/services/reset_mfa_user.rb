# frozen_string_literal: true

module Yuzakan
  module Services
    class ResetMfaUser < Yuzakan::ServiceOperation
      include Deps["services.list_user"]

      category :user

      def call(service, username)
        return unless can_call?(service, :user_reset_mfa)

        username = step validate_name(username)
        list = step list_user.call(service)
        return unless list.include?(username)

        adapter = step get_adapter(service)
        adapter.user_reset_mfa(username)
      end
    end
  end
end
