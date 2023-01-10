# frozen_string_literal: true

require 'hanami/action/cache'

module Admin
  module Controllers
    module Config
      class Edit
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :client

        def call(params)
        end
      end
    end
  end
end
