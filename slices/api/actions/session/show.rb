# frozen_string_literal: true

module API
  module Actions
    module Session
      class Show < API::Action
        security_level 0
        required_authentication false

        def handle(req, res)
          res[:session] = req.session
        end
      end
    end
  end
end
