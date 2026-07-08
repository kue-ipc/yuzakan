# frozen_string_literal: true

require "hanami"

# FIXME: Exposureの@objectは親のViewになるため、inspectがループする。
class Hanami::View::Exposure
  def inspect
    keys = [:name, :proc, :options]
    klass = self.class
    name  = klass.name || klass.inspect
    "#<#{name}#{keys.map { |key| " #{key}=#{__send__(key).inspect}" }.join}>"
  end
end

# Sequel timezone
Sequel.default_timezone = :local

module Yuzakan
  class App < Hanami::App
    config.views.default_template_engine = "slim"

    config.i18n.default_locale = settings.locale.intern
    config.i18n.available_locales = [:ja, :en]
    config.i18n.fallbacks = true

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
      "management.complete_affiliation",
      "management.complete_group",
      "management.complete_user",
      "management.sync_group",
      "management.sync_user",
    ]
  end
end
