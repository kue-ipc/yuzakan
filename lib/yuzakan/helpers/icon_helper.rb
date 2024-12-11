# frozen_string_literal: true

module Yuzakan
  module Helpers
    module IconHelper
      private def bs_icon(name, size: 24, alt: nil, **opts)
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

        html.svg(**svg_opts) do
          html.empty_tag :use,
                         "xlink:href": "/assets/vendor/bootstrap-icons.svg##{name}"
        end
      end
    end
  end
end
