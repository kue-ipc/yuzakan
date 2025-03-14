# auto_register: false
# frozen_string_literal: true

require "hanami/view"
require "slim"

module Yuzakan
  class View < Hanami::View
    expose :current_config, as: :config, layout: true
    expose :current_user, as: :user, layout: true
    expose :current_level, layout: true
  end
end
