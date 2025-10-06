# frozen_string_literal: true

# TODO: 見直し必要

module Yuzakan
  module Services
    class Authenticate < Yuzakan::ServiceOperation
      category :service

      def call(service)
        services = step get_services([service])
        step authenticate(username, password, services)
      end

      private def authenticate(_username, _password, services)
        services.each do |service|
          adapter = step get_adapter(service)
          adapter.status
          return Success(adapter.status)
        rescue => e
          return Failure([:error, e])
        end

        Failure([:failure, t("errors.wrong_username_or_password")])
      end
    end
  end
end
