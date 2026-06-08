# frozen_string_literal: true

module API
  module Views
    module Adapters
      class Show < API::View
        expose :adapter
        expose :restricted, decorate: false do |current_level|
          current_level < 4
        end
      end
    end
  end
end
