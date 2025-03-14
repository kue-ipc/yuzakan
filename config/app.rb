# frozen_string_literal: true

require "hanami"

require "rack/session/redis"

# Sequel timezone
Sequel.default_timezone = :local

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
    config.inflections do |inflections|
      inflections.acronym "AD"
    end
    config.actions.format :html
    config.shared_app_component_keys += [
      "repos.auth_log_repo",
      "repos.user_repo",
      "mgmt.sync_user",
      "providers.authenticate",
    ]
  end
end
