module Web
  module Views
    module User
      module Password
        class Edit
          include Web::View

          def form
            Form.new(:password, routes.user_password_path, {}, {method: :patch})
          end
        end
      end
    end
  end
end
