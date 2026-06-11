# frozen_string_literal: true

module Yuzakan
  module Services
    class ReadUser < Yuzakan::ServiceOperation
      include Deps["services.list_user"]

      category :user

      def call(service, username)
        return unless can_call?(service, :user_read)

        username = step validate_name(username)
        list = step list_user.call(service)
        return unless list.include?(username)

        cache_fetch(service, username) do
          adapter = step get_adapter(service)
          userdata = adapter.user_read(username)
          step convert_data(service, userdata)
        end
      end
    end
  end
end
