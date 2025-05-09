# frozen_string_literal: true

module Admin
  class Slice < Hanami::Slice
    import keys: ["assets", "routes"], from: Hanami.app.container, as: :app
  end
end
