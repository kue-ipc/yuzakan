module Legacy
  module Views
    module Dashboard
      class Index
        include Legacy::View

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
