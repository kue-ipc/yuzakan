# auto_register: false
# frozen_string_literal: true

module Admin
  class View < Yuzakan::View
    config.paths = ["slices/admin/templates", "app/templates"]
      .map { |path| Hanami.app.root.join(path) }
  end
end
