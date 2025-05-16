# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module BsHelper
        class BsBuilder < Hanami::View::Helpers::TagHelper::TagBuilder
          EscapeHelper = Hanami::View::Helpers::EscapeHelper

          # module
          include Form
          include List
          include Nav
        end
      end
    end
  end
end
