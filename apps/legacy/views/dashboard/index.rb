# frozen_string_literal: true

module Legacy
  module Views
    module Dashboard
      class Index
        include Legacy::View

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
              url: routes.edit_user_password_path,
              description: 'パスワードを変更します。',
            },
          ]
        end
      end
    end
  end
end
