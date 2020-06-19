# frozen_string_literal: true

module Web
  module Views
    module Dashboard
      class Index
        include Web::View

        def menu_link(name:, url:, description:)
          link_to url, class: 'card' do
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
            },
            {
              name: 'G Suite',
              url: routes.path(:gsuite),
              description: 'G Suite の Google アカウントの管理ができます。',
            },
          ]
        end
      end
    end
  end
end
