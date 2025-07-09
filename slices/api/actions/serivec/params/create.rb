# frozen_string_literal: true

module API
  module Actions
    module Services
      module Params
        class Create < Yuzakan::Action::Params
          params do
            required(:name).filled(:str?, :name?, max_size?: 255)
            optional(:label).maybe(:str?, max_size?: 255)
            required(:adapter).filled(:str?, :name?, max_size?: 255)
            optional(:order).filled(:int?)
            optional(:readable).filled(:bool?)
            optional(:writable).filled(:bool?)
            optional(:authenticatable).filled(:bool?)
            optional(:password_changeable).filled(:bool?)
            optional(:lockable).filled(:bool?)
            optional(:individual_password).filled(:bool?)
            optional(:self_management).filled(:bool?)
            optional(:group).filled(:bool?)
            optional(:params) { hash? }
          end
        end
      end
    end
  end
end
