# frozen_string_literal: true

module API
  module Actions
    module Session
      module Params
        class Create < API::Action::Params
          params do
            required(:username).filled(Yuzakan::Types::NameString, max_size?: 255)
            required(:password).filled(:string, max_size?: 255)
          end
        end
      end
    end
  end
end
