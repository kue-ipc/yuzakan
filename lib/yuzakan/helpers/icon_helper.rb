require 'octicons'

module Yuzakan
  module Helpers
    module IconHelper
      private def oi_icon(name, size: 16, alt: nil, **opts)
        raw Octicons::Octicon.new(name, height: size, width: size).to_svg
      end

      private def bs_icon(name, size: 16, alt: nil, **opts)
        svg_opts = {
          class: ['bi'],
          width: size,
          height: size,
          fill: 'currentColor',
        }

        case opts[:class]
        when Array
          svg_opts[:class].concat(opts[:class])
        when String
          svg_opts[:class].concat(opts[:class].split)
        end

        if alt
          svg_opts.merge!(role: 'img', 'aria-label': alt)
        end

        html.svg **svg_opts do
          html.empty_tag :use,
            'xlink:href': "/assets/bootstrap-icons.svg\##{name}"
        end
      end
    end
  end
end
