# frozen_string_literal: true

module API
  module Views
    module AcceptJson
      def self.included(view)
        view.class_eval do
          format :json
        end
      end
    end
  end
end
