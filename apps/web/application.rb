require 'hanami/helpers'
require 'hanami/assets'

module Web
  class Application < Hanami::Application
    configure do
      root __dir__

      load_paths << [
        'controllers',
        'views',
      ]

      routes 'config/routes'

      sassions_name = 'yuzakan:session:web'
      sessions_opts = {
        expire_after: 24 * 60 * 60,
        key: sassions_name.gsub(':', '.'),
      }

      # -- redis --
      sessions :redis,
               redis_server: "redis://127.0.0.1:6379/0/#{sassions_name}",
               **sessions_opts

      # -- memcached --
      # require 'rack/session/dalli'
      # sessions :dalli,
      #          namespace: sassions_name,
      #          **sessions_opts

      # -- cookie --
      # sessions :cookie,
      #          secret: ENV.fetch('WEB_SESSIONS_SECRET'),
      #          **sessions_opts

      layout :application

      templates 'templates'

      assets do
        require_relative '../../lib/yuzakan/utils/uglifier_es_compressor'
        javascript_compressor Yuzakan::Utils::UglifierEsCompressor.new

        stylesheet_compressor :sass

        sources << [
          'assets',
          '../../vendor/assets',
        ]
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
        include Web::Assets::Helpers
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
