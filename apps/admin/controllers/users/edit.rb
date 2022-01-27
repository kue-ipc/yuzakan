require 'hanami/action/cache'
require_relative './set_user'

module Admin
  module Controllers
    module Users
      class Edit
        include Admin::Action
        include Hanami::Action::Cache
        include SetUser

        cache_control :no_store

        expose :user

        def initialize(user_repository: UserRepository.new,
                       attr_repository: AttrRepository.new,
                       provider_repository: ProviderRepository.new,
                       attrs: nil,
                       providers: nil,
                       read_user: nil)
          @user_repository = user_repository
          @provider_repository = provider_repository
          @attr_repository = attr_repository

          @attrs = attrs || @attr_repository.all
          @providers = providers || @provider_repository.operational_all_with_adapter(:read).to_a
          @read_user = read_user ||
                       ReadUser.new(provider_repository: @provider_repository, providers: @providers)
        end

        def call(_params)
        end
      end
    end
  end
end
