# frozen_string_literal: true

require "hanami"

require "rack/session/redis"

# Sequel timezone
Sequel.default_timezone = :local

# i18n
require "i18n"
I18n.load_path << Dir["#{File.expand_path('locales', __dir__)}/*.yml"]
I18n.default_locale = :ja

module Yuzakan
  class App < Hanami::App
    config.actions.sessions =
      if settings.redis_url
        [:redis, {
          key: "yuzakan.session",
          expire_after: settings.session_expire,
          redis_server: "#{settings.redis_url}/yuzakan:session",
          expires_in: settings.session_expire,
        },]
      elsif settings.session_secret
        [:cookie, {
          key: "yuzakan.session",
          expire_after: settings.session_expire,
          secret: settings.session_secret,
        },]
      else
        [:pool, {
          key: "yuzakan.session",
          expire_after: settings.session_expire,
        },]
      end
    config.middleware.use :body_parser, :json
    config.inflections do |inflections|
      inflections.acronym "AD"
    end
    # config.shared_app_component_keys += ["repos.*_repo"]
  end
end
