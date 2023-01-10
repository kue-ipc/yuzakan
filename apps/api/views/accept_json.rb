# frozen_string_literal: true

module Api
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
