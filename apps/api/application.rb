require 'hanami/helpers'
require 'hanami/assets'

require_relative './controllers/authentication'
require_relative './controllers/configuration'

require_relative '../../lib/yuzakan/utils/uglifier_es_compressor'

module Api
  class Application < Hanami::Application
    configure do # rubocop:disable Metrics/BlockLength
      root __dir__
      load_paths << ['controllers', 'views']
      routes 'config/routes'

      # sessions
      sassions_name = 'yuzakan:session'
      sessions_opts = {
        expire_after: 24 * 60 * 60,
        key: sassions_name.gsub(':', '.'),
      }

      # -- redis --
      redis_url = ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/0')
      sessions :redis,
               redis_server: "#{redis_url}/#{sassions_name}",
               **sessions_opts

      # -- memcached --
      # require 'rack/session/dalli'
      # sessions :dalli,
      #          namespace: sassions_name,
      #          **sessions_opts

      # -- cookie --
      # sessions :cookie,
      #          secret: ENV.fetch('SESSIONS_SECRET'),
      #          **sessions_opts

      default_request_format :json
      default_response_format :json

      layout :application # It will load Api::Views::ApplicationLayout
      templates 'templates'

      assets do
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
        include Api::Assets::Helpers
        include Yuzakan::Helpers
      end
    end

    configure :development do
      handle_exceptions false
    end

    configure :test do
      handle_exceptions false

      # -- cookie --
      sessions :cookie, secret: ENV.fetch('SESSIONS_SECRET')
    end

    configure :production do
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