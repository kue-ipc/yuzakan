module Web
  module Views
    module User
      module Password
        class Edit
          include Web::View

          def form
            Form.new(:user, routes.user_password_path, {}, {method: :patch})
          end

          def change_password_config
            {
              min_size: 8,
              max_size: 32,
              min_score: 3,
            }
          end
        end
      end
    end
  end
end
