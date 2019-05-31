module Web
  module Controllers
    module Session
      class Create
        include Web::Action

        def call(params)
          user = UserRepository.new.auth(
            params[:session][:username],
            params[:session][:password]
          )
          if user
            session[:user_id] = user.id
            redirect_to routes.path(:dashboard)
          else
            redirect_to routes.path(:new_session)
          end
        end

        def authenticate!; end
      end
    end
  end
end
