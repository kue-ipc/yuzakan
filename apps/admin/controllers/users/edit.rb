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

        def initialize(config_repository: ConfigRepository.new,
                       user_repository: UserRepository.new,
                       attr_repository: AttrRepository.new,
                       provider_repository: ProviderRepository.new,
                       attrs: nil,
                       providers: nil,
                       read_user: nil)
          super(config_repository: config_repository, user_repository: user_repository)
          @attr_repository = attr_repository
          @provider_repository = provider_repository

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
