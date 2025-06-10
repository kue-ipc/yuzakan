# auto_register: false
# frozen_string_literal: true

module Admin
  module Views
    class Context < Yuzakan::Views::Context
      include Deps[
        app_assets: "app.assets",
        app_routes: "app.routes"
      ]
    end
  end
end
