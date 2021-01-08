# frozen_string_literal: true

require 'hanami/action/cache'

module Admin
  module Controllers
    module Setup
      class Done
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
        end

        def authenticate!
        end
      end
    end
  end
end
