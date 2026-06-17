# auto_register: false
# frozen_string_literal: true

module API
  class View < Yuzakan::View
    config.default_format = :json
    config.layout = nil

    expose :approved_level, decorate: false do
      2
    end

    expose :restricted, decorate: false do |current_level, approved_level|
      current_level < approved_level
    end
  end
end
