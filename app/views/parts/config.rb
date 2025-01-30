# frozen_string_literal: true

module Yuzakan
  module Views
    module Parts
      class Config < Yuzakan::Views::Part
        def config_tag
          helpers.tag.title(value.title)
        end
      end
    end
  end
end
