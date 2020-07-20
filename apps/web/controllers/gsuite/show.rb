# frozen_string_literal: true

module Web
  module Controllers
    module Gsuite
      class Show
        include Web::Action

        expose :gsuite_provider
        expose :gsuite_user
        expose :creatable

        def call(_params)
          @gsuite_provider = ProviderRepository.new.first_gsuite_with_params
          @gsuite_user = @gsuite_provider.adapter.read(current_user.name)

          @creatable = false
          unless @gsuite_user
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
