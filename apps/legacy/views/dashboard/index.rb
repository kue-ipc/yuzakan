# frozen_string_literal: true

module Legacy
  module Views
    module Dashboard
      class Index
        include Legacy::View

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
              url: routes.edit_user_password_path,
              description: 'パスワードを変更します。',
              color: 'primary',
            },
          ]
        end
      end
    end
  end
end
