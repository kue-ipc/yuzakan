require_relative '../../web/controllers/connection'

module Api
  module Connection
    include Web::Connection

    private def reply_session_timeout
      halt 400
    end
  end
end
