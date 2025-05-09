# auto_register: false
# frozen_string_literal: true

module Yuzakan
  class ValidationContract < Dry::Validation::Contract
    Types = Dry::Types()

    config.messages.top_namespace = ""
    config.messages.backend = :i18n
    config.messages.default_locale = Hanami.app["settings"].locale.intern
    config.types = Dry::Schema::TypeContainer.new.tap do |container|
      container.namespace(:params) do
        [:name, :email, :password, :host, :domain].each do |name|
          type = Types::String.constrained(format: Yuzakan::Patterns[name].ruby)
          container.register(name, type)
        end
      end
    end
  end
end
