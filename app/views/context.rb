# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    class Context < Hanami::View::Context
      # Define your view context here. See https://guides.hanamirb.org/views/context/ for details.

      include Deps[
        app_assets: "assets",
        app_routes: "routes",
      ]
    end
  end
end
