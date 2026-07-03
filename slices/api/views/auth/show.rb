# frozen_string_literal: true

module API
  module Views
    module Auth
      class Show < API::View
        decorate :auth
      end
    end
  end
end
