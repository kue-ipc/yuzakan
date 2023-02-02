# frozen_string_literal: true

require 'bundler/setup'
require 'hanami/setup'
require 'hanami/model'
require 'hanami/middleware/body_parser'
require_relative '../lib/yuzakan'
require_relative '../apps/admin/application'
require_relative '../apps/api/application'
require_relative '../apps/web/application'
require_relative '../apps/vendor/application'

# Opal Tilt Template
require 'tilt/opal'

# CoffeeScript v2 (from node_modulses)
ENV['COFFEESCRIPT_SOURCE_PATH'] ||= File.expand_path(
  '../node_modules/coffeescript/lib/coffeescript-browser-compiler-legacy/coffeescript.js', __dir__)

Hanami.configure do
  mount Vendor::Application, at: '/vendor'
  mount Admin::Application, at: '/admin'
  mount Api::Application, at: '/api'
  mount Web::Application, at: '/'

  model do
    ##
    # Database adapter
    #
    # Available options:
    #
    #  * SQL adapter
    #    adapter :sql, 'sqlite://db/yuzakan_development.sqlite3'
    #    adapter :sql, 'postgresql://localhost/yuzakan_development'
    #    adapter :sql, 'mysql://localhost/yuzakan_development'
    #
    adapter :sql, ENV.fetch('DATABASE_URL')

    ##
    # Migrations
    #
    migrations 'db/migrations'
    schema     'db/schema.sql'
  end

  mailer do
    root 'lib/yuzakan/mailers'

    # See http://hanamirb.org/guides/mailers/delivery
    delivery :test

    prepare do
      include Mailers::DefaultSender
      include Mailers::Partial
    end
  end

  environment :development do
    # See: http://hanamirb.org/guides/projects/logging
    logger level: :debug, filter: %w[
      password
      password_current
      password_confirmation
      bind_password
    ]

    mailer do
      delivery :logger
    end
  end

  environment :test do
    logger level: :fatal
  end

  environment :production do
    logger 'daily', level: :info,
                    formatter: :json,
                    stream: 'log/production.log',
                    filter: %w[
                      password
                      password_current
                      password_confirmation
                      bind_password
                    ]

    mailer do
      delivery :smtp, address: ENV.fetch('SMTP_HOST'),
                      port: ENV.fetch('SMTP_PORT')
    end
  end

  # json request
  middleware.use Hanami::Middleware::BodyParser, :json

  # i18n
  I18n.load_path << Dir["#{File.expand_path('config/locales')}/*.yml"]
  I18n.default_locale = :ja
end
