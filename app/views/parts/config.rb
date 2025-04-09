# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Parts
      class Config < Yuzakan::Views::Part
        def title
          value.title
        end

        def title_tag
          helpers.tag.title(title)
        end

        def title_link_tag(url = context.routes.path(:root), **, &)
          if block_given?
            helpers.link_to(url, **, &)
          else
            helpers.link_to(title, url, **)
          end
        end
      end
    end
  end
end
