# frozen_string_literal: true

module API
  module Views
    module Groups
      class Show < API::View
        decorate :group
      end
    end
  end
end
