# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module TitleHelper
        def title_h_tag(level = 2, opts = {})
          route_path = _context.request.path.split("/").reject(&:empty?).join("_")
          route_path = "root" if route_path.empty?
          str = t("views.#{route_path}.title")
          case level
          in 1
            tag.h1(str, **opts)
          in 2
            tag.h2(str, **opts)
          in 3
            tag.h3(str, **opts)
          in 4
            tag.h4(str, **opts)
          in 5
            tag.h5(str, **opts)
          in 6
            tag.h6(str, **opts)
          end
        end

        private def route_path
          path_list = _context.request.path.delete_prefix("/").split("/")
          case path_list.last
          in nil | ""
            ["root"]
          in "*"
            # TODO: ここがまだ未実装
            path_list[0, ], "new"]
          in "!"
            [path_list, "edit"]
          else
            path_list
          end.join("_").intern
          route_path = _context.request.path.split("/").reject(&:empty?).join("_")
          route_path = "root" if route_path.empty?

        end
      end
    end
  end
end
