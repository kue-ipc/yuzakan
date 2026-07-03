# frozen_string_literal: true

module API
  module Views
    module Attrs
      class Index < API::View
        decorate :attrs
        expose :restricted do |current_level|
          current_level < 4
        end
      end
    end
  end
end
