# frozen_string_literal: true

module API
  class Slice < Hanami::Slice
    # NOTE: Cannot use `config.actions.format :json` here because middleware use :body_parser with default :json
  end
end
