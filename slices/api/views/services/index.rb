# frozen_string_literal: true

module API
  module Views
    module Services
      class Index < API::View
        decorate :services
        expose :restricted do |current_level|
          current_level < 4
        end
      end
    end
  end
end
