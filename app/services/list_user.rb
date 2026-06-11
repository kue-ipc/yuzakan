# frozen_string_literal: true

module Yuzakan
  module Services
    class ListUser < Yuzakan::ServiceOperation
      category :user

      def call(service)
        return unless can_call?(service, :user_list)

        cache_fetch(service) do
          adapter = step get_adapter(service)
          adapter.user_list
        end
      end
    end
  end
end
