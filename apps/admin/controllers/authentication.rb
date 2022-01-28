require_relative '../../web/controllers/authentication'

module Admin
  module Authentication
    include Web::Authentication

    private def authenticate!
      super
      administrate!
    end

    private def administrate!
      return if current_user&.admin

      halt 403
    end
  end
end
