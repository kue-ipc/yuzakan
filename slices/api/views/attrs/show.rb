# frozen_string_literal: true

module API
  module Views
    module Attrs
      class Show < API::View
        decorate :attr
        expose :restricted do |current_level|
          current_level < 4
        end
      end
    end
  end
end
