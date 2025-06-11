# frozen_string_literal: true

module API
  module Views
    module Error
      class Halt < API::View
        expose :has_data, decorate: false, layout: true do
          false
        end
      end
    end
  end
end
