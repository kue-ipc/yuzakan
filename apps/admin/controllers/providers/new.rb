# frozen_string_literal: true

require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      class New
        include Admin::Action
        expose :provider
        include Hanami::Action::Cache

        cache_control :no_store

        def call(_params)
          @provider = nil
        end
      end
    end
  end
end
