# frozen_string_literal: true

module Yuzakan
  module Views
    module Parts
      class Config < Yuzakan::Views::Part
        def title_tag
          helpers.tag.title(value.title)
        end

        def title_link_tag(url = _context.routes.path(:root), **)
          helpers.link_to(value.title, url, **)
        end
      end
    end
  end
end
