# frozen_string_literal: true

module Yuzakan
  module Validation
    class Contract < Dry::Validation::Contract
      config.messages.backend = :i18n
      config.messages.default_locale = Hanami.app["settings"].locale.intern
      Hanami.app.root.glob("config/i18n/dry_validation/*.yml").each do |path|
        config.messages.load_paths << path
      end
    end
  end
end
