# frozen_string_literal: true

module API
  module Views
    module Services
      class Show < API::View
        expose :service
        expose :restricted, decorate: false do |current_level|
          current_level < 4
        end
      end
    end
  end
end
