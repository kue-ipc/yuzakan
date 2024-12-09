# frozen_string_literal: true

module Yuzakan
  module Helpers
    module MenuHelper
      private def menu_link(name: nil, url: nil, description: nil, color: 'dark', filled: false, type: :link,
        filename: nil)
        card_class = if filled then ['card', 'text-white', "bg-#{color}"] else ['card', "border-#{color}"] end
        if name
          html.div class: col_card + ['my-1'] do
            case type
            when :link
              link_to url, class: card_class do
                div name, class: 'card-header text-center'
                div description, class: 'card-body'
              end
            when :modal
              link_to url, class: card_class, 'data-bs-toggle': 'modal', 'data-bs-target': url do
                div name, class: 'card-header text-center'
                div description, class: 'card-body'
              end
            when :download
              link_to url, class: card_class, download: filename do
                div name, class: 'card-header text-center'
                div description, class: 'card-body'
              end
            end
          end
        else
          html.hr class: 'col-12 my-2'
        end
      end
    end
  end
end
