# frozen_string_literal: true

module Yuzakan
  module Validation
    class ActionContract < Contract
      MAX_STRING_SIZE = 255
      MAX_TEXT_SIZE = 65535

      [:name, :email, :password, :host, :domain].each do |name|
        register_macro(name) do
          key.failure(Hanami.app["i18n"].t("errors.#{name}?")) unless Yuzakan::Patterns[name].ruby =~ value
        end
      end

      register_macro(:name_or_current) do
        unless value == "~" || Yuzakan::Patterns[:name_or_current].ruby =~ value
          key.failure(Hanami.app["i18n"].t("errors.name_or_current?"))
        end
      end
    end
  end
end
