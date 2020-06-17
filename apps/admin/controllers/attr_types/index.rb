module Admin
  module Controllers
    module AttrTypes
      class Index
        include Admin::Action

        expose :attr_types
        expose :providers

        def call(_params)
          @attr_types = AttrTypeRepository.new.all_with_mappings
          @providers = ProviderRepository.new.all
        end
      end
    end
  end
end
