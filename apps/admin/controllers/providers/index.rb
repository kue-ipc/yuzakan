require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      class Index
        include Admin::Action
        expose :providers
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @providers = ProviderRepository.new.all
        end
      end
    end
  end
end
