# frozen_string_literal: true

module Yuzakan
  module Validation
    class ActionContract < Contract
      Types = Dry::Types()

      config.types = Dry::Schema::TypeContainer.new.tap do |container|
        container.namespace(:params) do
          [:name, :email, :password, :host, :domain, :name_or_symbol].each do |name|
            type = Types::String.constrained(format: Yuzakan::Patterns[name].ruby)
            container.register(name, type)
          end
        end
      end
    end
  end
end
