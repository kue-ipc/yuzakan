module Admin
  module Controllers
    module Session
      class Delete
        include Admin::Action

        def call(params)
          self.body = 'OK'
        end
      end
    end
  end
end
