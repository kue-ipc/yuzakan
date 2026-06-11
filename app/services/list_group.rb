# frozen_string_literal: true

module Yuzakan
  module Services
    class ListGroup < Yuzakan::ServiceOperation
      category :group

      def call(service)
        return unless can_call?(service, :group_list)

        cache_fetch(service) do
          adapter = step get_adapter(service)
          adapter.group_list
        end
      end
    end
  end
end
