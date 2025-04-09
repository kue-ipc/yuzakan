# frozen_string_literal: true

module User
  class Routes < Hanami::Routes
    root to: "home.index"

    get "/password/!", to: "password.edit", as: :edit_password
    get "/providers/:id", to: "providers.show", as: :provider
  end
end
