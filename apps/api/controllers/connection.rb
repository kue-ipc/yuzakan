require_relative '../../web/controllers/connection'

module Api
  module Connection
    include Web::Connection

    private def reply_session_timeout
      halt_json 400, 'セッションがタイムアウトしました。'
    end
  end
end