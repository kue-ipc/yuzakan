# frozen_string_literal: true

require_relative 'helpers/alert_helper'
require_relative 'helpers/error_helper'
require_relative 'helpers/escape_helper'
require_relative 'helpers/grid_helper'
require_relative 'helpers/icon_helper'
require_relative 'helpers/importmap_helper'
require_relative 'helpers/menu_helper'
require_relative 'helpers/pattern_helper'

module Yuzakan
  module Helpers
    def self.included(base)
      base.class_eval do
        include Yuzakan::Helpers::AlertHelper
        include Yuzakan::Helpers::ErrorHelper
        include Yuzakan::Helpers::EscapeHelper
        include Yuzakan::Helpers::GridHelper
        include Yuzakan::Helpers::IconHelper
        include Yuzakan::Helpers::ImportmapHelper
        include Yuzakan::Helpers::MenuHelper
        include Yuzakan::Helpers::PatternHelper
      end
    end
  end
end
