# frozen_string_literal: true

require 'hanami/helpers'
require 'hanami/assets'

module Legacy
  class Application < Hanami::Application
    configure do
      root __dir__

      load_paths << [
        'controllers',
        'views',
      ]

      routes 'config/routes'

      sessions :cookie, secret: ENV['WEB_SESSIONS_SECRET']

      layout :application

      templates 'templates'

      assets do
        require_relative '../../lib/yuzakan/utils/uglifier_es_compressor'
        javascript_compressor Yuzakan::Utils::UglifierEsCompressor.new

        stylesheet_compressor :sass

        sources << ['assets']
      end

      security.x_frame_options 'DENY'
      security.x_content_type_options 'nosniff'
      security.x_xss_protection '1; mode=block'
      security.content_security_policy %(
        form-action 'self';
        frame-ancestors 'self';
        base-uri 'self';
        default-src 'none';
        script-src 'self';
        connect-src 'self';
        img-src 'self' https: data:;
        style-src 'self' 'unsafe-inline' https:;
        font-src 'self';
        object-src 'none';
        plugin-types application/pdf;
        child-src 'self';
        frame-src 'self';
        media-src 'self'
      )

      controller.prepare do
        include Configuration
        include Authentication
        before :configurate!
        before :authenticate!
        expose :current_config
        expose :current_user
        expose :remote_ip
      end

      view.prepare do
        include Hanami::Helpers
        include Legacy::Assets::Helpers
        include Yuzakan::Helpers
      end
    end

    configure :development do
      handle_exceptions false
    end

    configure :test do
      handle_exceptions false
    end

    configure :production do
      # for debug
      handle_exceptions false

      scheme 'https'
      host   ENV['HOST']
      port   443

      assets do
        compile false
        fingerprint true
        subresource_integrity :sha256
      end
    end
  end
end
