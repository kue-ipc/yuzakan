require_relative '../../web/controllers/authentication'

module Api
  module Authentication
    include Web::Authentication

    private def reply_unauthenticated
      halt_json 401
    end
  end
end
