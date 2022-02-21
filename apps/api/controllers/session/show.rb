module Api
  module Controllers
    module Session
      class Show
        include Api::Action

        def call(params)
          self.body = JSON.generate({
            uuid: session[:uuid],
            username: current_user.name,
            display_name: current_user.display_name,
          })
        end
      end
    end
  end
end
