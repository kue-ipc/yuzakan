# auto_register: false
# frozen_string_literal: true

module API
  class View < Yuzakan::View
    config.default_format = :json
    expose :status, layout: true
    expose :location, decorate: false, layout: true
    expose :has_data, decorate: false, layout: true do
      true
    end
  end
end
