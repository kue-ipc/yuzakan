# frozen_string_literal: true

module Yuzakan
  class ValidationContract < Dry::Validation::Contract
    config.messages.top_namespace = ""
    config.messages.backend = :i18n
    config.messages.default_locale = Hanami.app["settings"].locale.intern
  end
end
