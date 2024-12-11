# frozen_string_literal: true

require "hanami"

# CoffeeScript v2 (from node_modulses)
ENV["COFFEESCRIPT_SOURCE_PATH"] ||= File.expand_path(
  "../node_modules/coffeescript/lib/coffeescript-browser-compiler-legacy/coffeescript.js", __dir__)

# Sequel timezone
Sequel.application_timezone = :local

# i18n
require "i18n"
I18n.load_path << Dir["#{File.expand_path('locales', __dir__)}/*.yml"]
I18n.default_locale = :ja

# Adapter
require_relative "../lib/yuzakan/adapters"
ADAPTERS_MANAGER = Yuzakan::Adapters::Manager.new

module Yuzakan
  class App < Hanami::App
    config.actions.sessions = :cookie, {
      key: "yuzakan.session",
      secret: settings.session_secret,
      expire_after: 60 * 60 * 24 * 365,
    }
    # config.shared_app_component_keys += ["repos.*_repo"]
    config.middleware.use :body_parser, :json
  end
end
