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

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @pagy_data, @users = pagy(UserRepository.new)
          @providers = ProviderRepository.new
            .ordered_all_with_adapter_by_operation(:list).to_a
          @provider_users = @providers.each.to_h do |provider|
            [provider.id, provider.list]
          end
        end
      end
    end
  end
end
