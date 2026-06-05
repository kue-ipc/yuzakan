# auto_register: false
# frozen_string_literal: true

module API
  class View < Yuzakan::View
    config.default_format = :json
    expose :status, layout: true
    expose :location, decorate: false, layout: true
    expose :pager, layout: true
  end
end
