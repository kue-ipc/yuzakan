# frozen_string_literal: true

module API
  class Slice < Hanami::Slice
    if Hanami.env?(:development)
      config.actions.format :json, :html
    else
      config.actions.format :json
    end
  end
end
