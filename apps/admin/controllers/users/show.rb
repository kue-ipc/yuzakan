require 'hanami/action/cache'

module Admin
  module Controllers
    module Users
      class Show
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :user
        expose :user_attrs
        expose :user_providers_attrs
        expose :providers
        expose :provider_datas
        expose :attrs

        def call(params)
          user_id = params[:id]
          @user = UserRepository.new.find(user_id)

          halt 404 unless @user

          @providers = ProviderRepository.new.operational_all_with_adapter(:read)
          result = UserAttrs.new(readable_providers: @providers).call(username: @user.name)
          @user_attrs = result.attrs
          @user_providers_attrs = result.providers_attrs

          @attrs = AttrRepository.new.all
        end
      end
    end
  end
end
