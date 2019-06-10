# frozen_string_literal: true

module Admin
  module Controllers
    module Providers
      class Index
        include Admin::Action
        expose :providers

        def call(params)
          @providers = ProviderRepository.new.all
        end
      end
    end
  end
end
