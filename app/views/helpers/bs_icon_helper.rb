# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module BsIconHelper
        def bs_icon_tag(name, size: 24, alt: nil, **opts)
          svg_opts = {
            class: ["bi", opts[:class]],
            width: size,
            height: size,
            fill: "currentColor",
          }
          svg_opts.merge!(role: "img", "aria-label": alt) if alt
          tag.svg(**svg_opts) do
            tag.use("xlink:href": bs_icon_svg_link(name))
          end
        end

        def bs_icon_svg
          _context.assets["bootstrap-icons.svg"]
        end

        def bs_icon_svg_link(name)
          "#{bs_icon_svg}##{name}"
        end
      end
    end
  end
end
