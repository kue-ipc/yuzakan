# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module MenuHelper
        USER_STATIC_MENU_ITEMS = [
          {name: :user_password, color: "primary", level: 0},
        ].freeze

        ADMIN_STATIC_MENUE_ITEMS = [
          {name: :admin_user, params: {id: "*"}, color: "primary", level: 4},
          {name: :admin_users, color: "secondary", level: 2},
          {name: :admin_groups, color: "secondary", level: 2},
          {name: :admin_config, color: "danger", level: 5},
          {name: :admin_providers, color: "danger", level: 2},
          {name: :admin_attrs, color: "danger", level: 5},
          {name: :admin_export_users, color: "warning", level: 5},
          {name: :admin_export_groups, color: "warning", level: 5},
        ].freeze

        # TODO: プロバイダー
        def user_menu_list(level)
          USER_STATIC_MENU_ITEMS
            .select { |item| item[:level] <= level }
            .map do |item|
              {**item, path: _context.routes.path(item[:name])}
            end
        end

        def admin_menu_list(level)
          ADMIN_STATIC_MENU_ITEMS.select { |item| item[:level] <= level }
        end

        def menu_link(name: nil, url: nil, description: nil, color: "dark", filled: false, type: :link,
          filename: nil)
          card_class = if filled then ["card", "text-white",
            "bg-#{color}",] else
                              ["card",
                                "border-#{color}",] end
          if name
            html.div class: col_card + ["my-1"] do
              case type
              when :link
                link_to url, class: card_class do
                  div name, class: "card-header text-center"
                  div description, class: "card-body"
                end
              when :modal
                link_to url, class: card_class, "data-bs-toggle": "modal",
                  "data-bs-target": url do
                  div name, class: "card-header text-center"
                  div description, class: "card-body"
                end
              when :download
                link_to url, class: card_class, download: filename do
                  div name, class: "card-header text-center"
                  div description, class: "card-body"
                end
              end
            end
          else
            html.hr class: "col-12 my-2"
          end
        end
      end
    end
  end
end
