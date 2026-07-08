# frozen_string_literal: true

module Yuzakan
  module Validation
    class ActionContract < Contract
      [:name, :email, :password, :host, :domain].each do |name|
        register_macro(name) do
          key.failure(Hanami.app["i18n"].t("errors.#{name}?")) unless Yuzakan::Patterns[name].ruby =~ value
        end
      end
    end
  end
end
