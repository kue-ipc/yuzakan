require 'hanami/action/cache'

module Admin
  module Controllers
    module Users
      class Show
        include Admin::Action
        include Hanami::Action::Cache
        include Yuzakan::Helpers::NameChecker

        cache_control :no_store

        expose :user
        expose :user_attrs
        expose :user_providers_attrs
        expose :providers
        expose :provider_datas
        expose :attrs

        def call(params)
          user_id = params[:id]
          @user =
            case check_type(user_id)
            when :id
              UserRepository.new.find(user_id)
            when :name
              UserRepository.new.find_by_name_or_sync(user_id)
            else
              halt 400
            end

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
