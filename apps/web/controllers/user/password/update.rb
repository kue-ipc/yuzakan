module Web
  module Controllers
    module User
      module Password
        class Update
          include Web::Action

          def initailze
            @change_password = ChangePassword.new
          end

          def call(params)
            @change_password.call(
              params[:user].merge(username: current_user.name))
          end
        end
      end
    end
  end
end
