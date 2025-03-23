# frozen_string_literal: true

module User
  module Actions
    module Home
      class Index < User::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :user
        expose :user_attrs
        expose :attrs

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
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
