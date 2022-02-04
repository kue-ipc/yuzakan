require 'hanami/action/cache'
require_relative './set_user'

module Admin
  module Controllers
    module Users
      class Show
        include Admin::Action
        include Hanami::Action::Cache
        include SetUser

        cache_control :no_store

        expose :user
        expose :userdata
        expose :provider_userdatas

        expose :providers
        expose :attrs

        def initialize(attr_repository: AttrRepository.new,
                       provider_repository: ProviderRepository.new,
                       attrs: nil,
                       providers: nil,
                       read_user: nil, **opts)
          super(**opts)
          @provider_repository = provider_repository
          @attr_repository = attr_repository

          @attrs = attrs || @attr_repository.all
          @providers = providers || @provider_repository.operational_all_with_adapter(:read).to_a
          @read_user = read_user ||
                       ReadUser.new(provider_repository: @provider_repository, providers: @providers)
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          result = @read_user.call(username: @user.name)
          flash[:errors] = result.errors if result.failure?
          @userdata = result.userdata || {}
          @provider_userdatas = result.provider_userdatas || {}
        end
      end
    end
  end
end
