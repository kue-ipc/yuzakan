require 'hanami/action/cache'

module Admin
  module Controllers
    module Users
      class Index
        include Admin::Action
        include Hanami::Action::Cache
        include Pagy::Backend

        cache_control :no_store

        expose :pagy_data

        expose :users
        expose :providers
        expose :provider_users

        def call(_params)
          @pagy_data, @users = pagy(UserRepository.new)
          @providers = ProviderRepository.new
            .operational_all_with_adapter(:list).to_a
          @provider_users = @providers.each.to_h do |provider|
            [provider.id, provider.list]
          end
        end
      end
    end
  end
end
