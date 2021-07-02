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

        def call(_params)
          @google_provider = ProviderRepository.new.first_google_with_params
          @google_user = @google_provider.adapter.read(current_user.name)

          @creatable = false
          unless @google_user
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
end
