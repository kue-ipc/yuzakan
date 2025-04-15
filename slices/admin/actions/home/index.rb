# frozen_string_literal: true

require "hanami/action/cache"

module Admin
  module Actions
    module Home
      class Index < Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def handle(request, response)
        end
      end
    end
  end
end
