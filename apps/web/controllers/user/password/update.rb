# frozen_string_literal: true

module Web
  module Controllers
    module User
      module Password
        class Update
          include Web::Action

          expose :succeeded

          def initialize
            @change_password = ChangePassword.new
          end

          def call(params)
            result = @change_password.call(
              username: current_user.name,
              password: params[:user][:password],
            )
            if result
              @succeeded = true
            else
              @succeeded = false
            end
          end
        end
      end
    end
  end
end
