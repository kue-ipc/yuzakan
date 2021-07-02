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
              description: 'アカウントのパスワードを変更します。',
              color: 'primary',
            },
            {
              name: 'Google Workspace',
              url: routes.path(:google),
              description: 'Googleアカウントを管理します。',
              color: 'secondary',
            },
          ]
        end
      end
    end
  end
end
