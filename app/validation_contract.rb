# auto_register: false
# frozen_string_literal: true

module Yuzakan
  class ValidationContract < Dry::Validation::Contract
    config.messages.top_namespace = ""
    config.messages.backend = :i18n
    config.messages.default_locale = Hanami.app["settings"].locale.intern
    config.types = Dry::Schema::TypeContainer.new.tap do |container|
      container.namespace(:params) do
        container.register(:name, Yuzakan::Types::NameString)
        container.register(:email, Yuzakan::Types::EmailString)
        container.register(:password, Yuzakan::Types::PasswordString)
        container.register(:host, Yuzakan::Types::HostString)
        container.register(:domain, Yuzakan::Types::DomainString)
      end
    end
  end
end
