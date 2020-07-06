# frozen_string_literal: true

module Web
  module Controllers
    module User
      class Show
        include Web::Action

        expose :user
        expose :user_attrs
        expose :attrs

        def call(_params)
          provider_attr_mapping_repository = AttrMappingRepository.new

          @user = current_user

          providers = ProviderRepository.new.operational_all_with_params(:read)
          provider_datas = providers.each.map do |provider|
            provider.adapter.read(@user.name,
                                  provider_attr_mapping_repository
                                    .by_provider_with_attr(provider.id))
          end
          @user_attrs = provider_datas.compact.inject({}) do |result, data|
            data.merge(result)
          end

          @attrs = AttrRepository.new.all
        end
      end
    end
  end
end
