# frozen_string_literal: true

module API
  module Views
    module Error
      class Halt < API::View
        decorate :error
      end
    end
  end
end
