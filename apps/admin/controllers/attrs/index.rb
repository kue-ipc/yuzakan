# frozen_string_literal: true

module Admin
  module Controllers
    module Attrs
      class Index
        include Admin::Action

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
