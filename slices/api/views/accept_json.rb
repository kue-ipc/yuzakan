# frozen_string_literal: true

# FIXME: 別の所で設定だと思われる。

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
