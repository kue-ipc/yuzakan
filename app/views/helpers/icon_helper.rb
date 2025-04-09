# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module IconHelper
        def bs_icon_tag(name, size: 24, alt: nil, **opts)
          svg_opts = {
            class: ["bi"],
            width: size,
            height: size,
            fill: "currentColor",
          }

          case opts[:class]
          when Array
            svg_opts[:class].concat(opts[:class])
          when String
            svg_opts[:class].concat(opts[:class].split)
          end

          svg_opts.merge!(role: "img", "aria-label": alt) if alt

          icons_svg = _context.assets["bootstrap-icons.svg"]

          tag.svg(**svg_opts) do
            tag.use(:use, "xlink:href": "#{icons_svg}##{name}")
          end
        end
      end
    end
  end
end
