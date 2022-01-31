require_relative '../../web/controllers/configuration'

module Api
  module Configuration
    include Web::Configuration

    private def reply_uninitialized
      halt 503
    end

    private def reply_maintenance
      halt 503
    end
  end
end
