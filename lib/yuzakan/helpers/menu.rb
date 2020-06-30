# frozen_string_literal: true

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
          if type == :link
            link_to url, class: card_class do
              div name, class: 'card-header text-center'
              div description, class: 'card-body'
            end
          elsif type == :modal
            link_to url, class: card_class, 'data-toggle': 'modal',
                         'data-target': url do
              div name, class: 'card-header text-center'
              div description, class: 'card-body'
            end
          end
        end
      end
    end
  end
end
