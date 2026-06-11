# frozen_string_literal: true

module Yuzakan
  module Services
    class LockUser < Yuzakan::ServiceOperation
      include Deps["services.list_user"]

      category :user

      def call(service, username)
        return unless can_call?(service, :user_lock)

        username = step validate_name(username)
        list = step list_user.call(service)
        return unless list.include?(username)

        adapter = step get_adapter(service)
        adapter.user_lock(username).tap do |result|
          cache_delete(service, username) if result
        end
      end
    end
  end
end
