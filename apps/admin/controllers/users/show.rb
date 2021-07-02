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
        expose :providers
        expose :provider_datas
        expose :attrs

        def call(params)
          user_id = params[:id]
          if user_id =~ /\A\d+\z/
            @user = UserRepository.new.find(params[:id])
          else
            @user = UserRepository.new.by_name(params[:id]).one
            @user ||= UserRepository.new.sync(params[:id])
          end

          halt 404 unless @user

          @providers = ProviderRepository.new.operational_all_with_params(:read)
          result = UserAttrs.new(readable_providers: @providers)
            .call(username: @user.name)
          @user_attrs = result.attrs
          @provider_datas = result.datas.values

          @attrs = AttrRepository.new.all
        end
      end
    end
  end
end
