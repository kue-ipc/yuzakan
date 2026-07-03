# frozen_string_literal: true

require "hanami"

# Sequel timezone
Sequel.default_timezone = :local

module Yuzakan
  class App < Hanami::App
    config.views.default_template_engine = "slim"

    config.middleware.use :body_parser, :json

    config.actions.formats.accept :html

    config.actions.sessions =
      if settings.redis_url
        require "rack/session/redis"
        [:redis, {
          key: "yuzakan.session",
          expire_after: settings.session_expire,
          redis_server: "#{settings.redis_url}/yuzakan:session",
          expires_in: settings.session_expire,
        }]
      elsif settings.session_secret
        [:cookie, {
          key: "yuzakan.session",
          expire_after: settings.session_expire,
          secret: settings.session_secret,
        }]
      else
        [:pool, {
          key: "yuzakan.session",
          expire_after: settings.session_expire,
        }]
      end

    config.inflections do |inflections|
      inflections.acronym "AD"
    end

    config.shared_app_component_keys += [
      "repos.affiliation_repo",
      "repos.auth_log_repo",
      "repos.config_repo",
      "repos.mapping_repo",
      "repos.user_repo",
      "management.authenticate",
      "management.change_password",
      "management.sync_user",
    ]
  end
end
