# frozen_string_literal: true

require_relative '../../web/controllers/configuration'

module Api
  module Configuration
    include Web::Configuration

    private def reply_uninitialized
      halt_json 503, errors: ['初期化されていません。']
    end
  end
end
