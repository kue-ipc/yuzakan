# frozen_string_literal: true

module Admin
  module Controllers
    module Users
      class Index
        include Admin::Action

        expose :users
        expose :providers
        expose :provider_users

        def call(_params)
          @users = UserRepository.new.all.map
          @providers = ProviderRepository.new.operational_all_with_params(:list)
          @provider_users = @providers.each.map do |provider|
            [provider.id, provider.adapter.list]
          end.to_h
        end
      end
    end
  end
end
