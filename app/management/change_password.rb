# frozen_string_literal: true

module Yuzakan
  module Management
    class ChangePassword < Yuzakan::ServiceOperation
      include Deps[
        "repos.service_repo",
        "services.change_password_user",
      ]

      def call(username, password)
        username = step validate_name(username)
        password = step validate_password(password)
        step change_password(username, password)
      end

      private def change_password(username, password)
        changed_services = service_repo.all.reject(&:individual_password).select do |service|
          step change_password_user.call(service, username, password)
        end

        Success(changed_services)
      end
    end
  end
end
