# frozen_string_literal: true

require "hanami"

# Sequel timezone
Sequel.default_timezone = :local

module Yuzakan
  class App < Hanami::App
    # config.middleware.use Yuzakan::Middleware::JsonKeyTraseformer
    require "yuzakan/middleware/body_parser/params_json_parser"
    config.middleware.use :body_parser, [Yuzakan::Middleware::BodyParser::ParamsJsonParser]

    config.actions.format :html

    config.actions.sessions =
      if settings.redis_url
        require "rack/session/redis"
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

    config.shared_app_component_keys += [
      "repos.auth_log_repo",
      "repos.affilation_repo",
      "repos.config_repo",
      "repos.mapping_repo",
      "repos.user_repo",
      "management.sync_user",
      "services.authenticate",
      "services.change_password",
    ]
  end
end
