require 'hanami/action/cache'

module Web
  module Controllers
    module Google
      class Show
        include Web::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :google_provider
        expose :google_user
        expose :creatable

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @google_provider = ProviderRepository.new.first_google_with_adapter
          @google_user = @google_provider.read(current_user.name)

          @creatable = false
          return if @google_user

          result = UserAttrs.new.call(username: current_user.name)
          if result.successful? &&
             ['学生', '教員', '職員'].include?(result.attrs[:affiliation])
            @creatable = true
          end
        end
      end
    end
  end
end
