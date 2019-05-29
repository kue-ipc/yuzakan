module Admin
  module Controllers
    module Setup
      class Create
        include Admin::Action

        def call(params)
          if params[:admin_user][:password] != params[:admin_user][:current_password]
            redirect_to routes.setup_path
          end
        end
      end
    end
  end
end
