# frozen_string_literal: true

module API
  module Views
    module Session
      class Show < API::View
        expose :session
      end
    end
  end
end
