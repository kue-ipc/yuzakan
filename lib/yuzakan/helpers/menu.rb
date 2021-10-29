module Yuzakan
  module Helpers
    module Menu
      private def menu_link(name:, url:, description:, color: 'dark',
                            filled: false, type: :link)
        card_class =
          if filled
            ['card', 'text-white', "bg-#{color}"]
          else
            ['card', "border-#{color}"]
          end
        html.div class: col_card + ['my-1'] do
          case type
          when :link
            link_to url, class: card_class do
              div name, class: 'card-header text-center'
              div description, class: 'card-body'
            end
          when :modal
            link_to url, class: card_class, 'data-bs-toggle': 'modal',
                         'data-bs-target': url do
              div name, class: 'card-header text-center'
              div description, class: 'card-body'
            end
          end
        end
      end
    end
  end
end
