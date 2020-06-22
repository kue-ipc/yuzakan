module Web
  module Controllers
    module User
      class Show
        include Web::Action

        expose :user
        expose :user_attrs
        expose :attr_types

        def call(_params)
          provider_attr_mapping_repository = ProviderAttrMappingRepository.new

          @user = current_user

          providers = ProviderRepository.new.operational_all_with_params(:read)
          provider_datas = providers.each.map do |provider|
            provider.adapter.read(@user.name,
                                  provider_attr_mapping_repository
                                    .by_provider_with_attr_type(provider.id))
          end
          @user_attrs = provider_datas.compact.inject({}) do |result, data|
            data.merge(result)
          end

          @attr_types = AttrTypeRepository.new.all
        end
      end
    end
  end
end
