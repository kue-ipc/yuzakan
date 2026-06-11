# frozen_string_literal: true

module Yuzakan
  module Services
    class GenerateCodeUser < Yuzakan::ServiceOperation
      include Deps["services.list_user"]

      category :user

      def call(service, username)
        return unless can_call?(service, :user_generate_code)

        username = step validate_name(username)
        list = step list_user.call(service)
        return unless list.include?(username)

        adapter = step get_adapter(service)
        adapter.user_generate_code(username)
      end
    end
  end
end
