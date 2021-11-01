module Yuzakan
  module Helpers
    module Icon
      private def icon(name, size: 16, **opts)
        svg_class = ['bi']
        case opts[:class]
        when Array
          svg_class.concat(opts[:class])
        when String
          svg_class.concat(opts[:class].split)
        end

        html.svg class: svg_class, width: size, height: size,
          fill: 'currentColor' do
          html.empty_tag :use,
            'xlink:href': '/assets/bootstrap-icons.svg#' + name
        end
      end
    end
  end
end
