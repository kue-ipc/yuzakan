# frozen_string_literal: true

# ユーザー名とパスワードを受け取り、認証に成功したサービスを返す。
module Yuzakan
  module Management
    class Authenticate < Yuzakan::ServiceOperation
      include Deps[
        "repos.service_repo",
        "services.auth_user",
      ]

      def call(username, password)
        username = step validate_name(username)
        password = step validate_password(password)
        step authenticate(username, password)
      end

      private def authenticate(username, password)
        service = service_repo.all.find do |service|
          step auth_user.call(service, username, password)
        end

        if service
          Success(service)
        else
          Failure([:failure, t("errors.wrong_username_or_password")])
        end
      end
    end
  end
end
