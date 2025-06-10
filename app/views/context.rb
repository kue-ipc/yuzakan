# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    class Context < Hanami::View::Context
      include Deps[
        "i18n",
        app_assets: "assets",
        app_routes: "routes"
      ]

      # I18n
      def t(...) = i18n.t(...)
      def l(...) = i18n.l(...)
    end
  end
end
