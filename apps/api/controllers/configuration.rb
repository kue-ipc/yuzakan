require_relative '../../web/controllers/configuration'

module Api
  module Configuration
    include Web::Configuration

    private def reply_uninitialized
      halt_json 503, '初期化されていません。'
    end

    private def reply_maintenance
      halt_json 503, 'メンテナンス中です。'
    end
  end
end
