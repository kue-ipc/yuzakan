# auto_register: false
# frozen_string_literal: true

require "hanami/view"
require "slim"

module Yuzakan
  class View < Hanami::View
    expose :current_config
  end
end
