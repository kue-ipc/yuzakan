module Web
  module Controllers
    module Session
      class Create
        include Web::Action

        def call(params)
          user = UserRepository.new.auth(
            pasams[:session][:username],
            pasams[:session][:password]
          )
          if user
            session[:usner_id] = user.id
            redirect_to routes.path(:dashboard)
          else
            redirect_to routes.path(:new_session)
          end
        end
      end
    end
  end
end
