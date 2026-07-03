# frozen_string_literal: true

module API
  module Views
    module Session
      class Show < API::View
        decorate :session
      end
    end
  end
end
