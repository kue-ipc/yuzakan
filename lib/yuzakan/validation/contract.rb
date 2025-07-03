# frozen_string_literal: true

module Yuzakan
  module Validation
    class Contract < Dry::Validation::Contract
      config.messages.top_namespace = ""
      config.messages.backend = :i18n
      config.messages.default_locale = Hanami.app["settings"].locale.intern
    end
  end
end
