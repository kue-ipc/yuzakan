# auto_register: false
# frozen_string_literal: true

module Admin
  module Views
    class Context < Yuzakan::Views::Context
      # Define your view context here. See https://guides.hanamirb.org/views/context/ for details.

      include Deps[
        app_assets: "app.assets",
        app_routes: "app.routes",
      ]
    end
  end
end
