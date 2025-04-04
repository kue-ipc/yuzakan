# frozen_string_literal: true

module Yuzakan
  module Views
    module Parts
      class Config < Yuzakan::Views::Part
        def title_tag
          helpers.tag.title(value.title)
        end

        def title_link_tag(url = routes.path(:root), **)
          link_to current_config.title, url, **
        end

        def config_
      end
    end
  end
end
