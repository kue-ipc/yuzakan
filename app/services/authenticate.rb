# frozen_string_literal: true

module Yuzakan
  module Services
    class Authenticate < Yuzakan::ServiceOperation
      category :user

      def call(username, password, services = nil)
        username = step validate_name(username)
        password = step validate_password(password)
        services = step get_services(services, method: :user_auth)
        step authenticate(username, password, services)
      end

      private def authenticate(username, password, services)
        services.each do |service|
          adapter = step get_adapter(service)
          return Success(service) if adapter.user_auth(username, password)
        rescue => e
          return Failure([:error, e])
        end

        Failure([:failure, t("errors.wrong_username_or_password")])
      end
    end
  end
end
