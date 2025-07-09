# frozen_string_literal: true

module Yuzakan
  module Services
    class ChangePassword < Yuzakan::ServiceOperation
      category :user

      def call(username, password, services = nil)
        username = step validate_name(username)
        password = step validate_password(password)
        services =
          if services.nil?
            all_services = step get_services(nil, method: :user_change_password)
            all_services.reject(&:individual_password)
          else
            step get_services(services, method: :user_change_password)
          end
        step change_password(username, password, services)
      end

      private def change_password(username, password, services)
        changed_services = services.select do |service|
          adapter = step get_adapter(service)
          adapter.user_change_password(username, password)
        rescue => e
          return Failure([:error, e])
        end

        Success[changed_services]
      end
    end
  end
end
