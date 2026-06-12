# frozen_string_literal: true

module API
  module Views
    module Attrs
      class Index < API::View
        expose :attrs
        expose :restricted, decorate: false do |current_level|
          current_level < 4
        end
      end
    end
  end
end
