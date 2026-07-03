# frozen_string_literal: true

module API
  module Views
    module Groups
      class Index < API::View
        decorate :groups
      end
    end
  end
end
