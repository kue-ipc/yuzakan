# frozen_string_literal: true

module API
  class Slice < Hanami::Slice
    config.actions.format :json
  end
end
