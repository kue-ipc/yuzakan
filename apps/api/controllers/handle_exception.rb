# frozen_string_literal: true

require_relative '../../web/controllers/handle_exception'

module Api
  module HandleException
    include Web::HandleException

    def handle_standard_error(e)
      Hanami.logger.error e
      halt_json 500
    end
  end
end
