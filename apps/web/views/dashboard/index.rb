# frozen_string_literal: true

module Web
  module Views
    module Dashboard
      class Index
        include Web::View

        def menu_link(name:, url:, description:, color: 'dark')
          bg_color = "bg-#{color}"
          link_to url, class: ['card', 'text-white', bg_color] do
            div name, class: 'card-header text-center'
            div description, class: 'card-body'
          end
        end

        def menu_items
          [
            {
              name: 'パスワード変更',
              url: routes.path(:edit_user_password),
              description: 'パスワード変更ができます。',
              color: 'primary',
            },
            {
              name: 'G Suite',
              url: routes.path(:gsuite),
              description: 'G Suite の Google アカウントの管理ができます。',
              color: 'secondary',
            },
          ]
        end
      end
    end
  end
end
