require_relative '../../web/controllers/authorization'

module Api
  module Authorization
    include Web::Authorization

    private def reply_unauthorized
      halt_json 403
    end
  end
end
