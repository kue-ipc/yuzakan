# frozen_string_literal: true

module Yuzakan
  module Params
    class Id < Hanami::Action::Params
      messages :i18n

      params do
        required(:id).value(Types::NameString, max_size?: 255)
      end
    end
  end
end