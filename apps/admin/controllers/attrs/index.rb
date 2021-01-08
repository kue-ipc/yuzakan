# frozen_string_literal: true

require 'hanami/action/cache'

module Admin
  module Controllers
    module Attrs
      class Index
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :attrs
        expose :providers

        def call(_params)
          @attrs = AttrRepository.new.all_with_mappings
          @providers = ProviderRepository.new.all
        end
      end
    end
  end
end
