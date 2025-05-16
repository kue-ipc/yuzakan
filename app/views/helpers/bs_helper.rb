# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module BsHelper
        include Hanami::View::Helpers::TagHelper

        def bs = bs_builder

        def bs_builder
          @bs_builder ||= BsBuilder.new(inflector: tag_builder_inflector)
        end
      end
    end
  end
end
