# frozen_string_literal: true

module Web
  module Views
    module Dashboard
      class Index
        include Web::View

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
