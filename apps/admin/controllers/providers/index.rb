require 'hanami/action/cache'

module Admin
  module Controllers
    module Providers
      class Index
        include Admin::Action
        expose :providers

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @providers = ProviderRepository.new.all
        end
      end
    end
  end
end
