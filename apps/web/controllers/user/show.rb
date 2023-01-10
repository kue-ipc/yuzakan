# frozen_string_literal: true

require 'hanami/action/cache'

module Web
  module Controllers
    module User
      class Show
        include Web::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :user
        expose :user_attrs
        expose :attrs

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @user = current_user

          providers = ProviderRepository.new.ordered_all_with_adapter_by_operation(:user_read)
          provider_datas = providers.each.map do |provider|
            provider.read(@user.name)&.[](:attrs)
          end
          @user_attrs = provider_datas.compact.inject({}) do |result, data|
            data.merge(result)
          end

          @attrs = AttrRepository.new.all_no_hidden
        end
      end
    end
  end
end
