module Web
  module Views
    module User
      module Password
        class Edit
          include Web::View

          def form_change_password
            form_for :password, routes.user_password_path, method: :patch do
              div id: 'change-password'
            end
          end
        end
      end
    end
  end
end
