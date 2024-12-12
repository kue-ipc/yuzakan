# frozen_string_literal: true

module Web
  module HandleException
    def handle_standard_error(e)
      Hanami.logger.error e
      halt 500
    end
  end
end
