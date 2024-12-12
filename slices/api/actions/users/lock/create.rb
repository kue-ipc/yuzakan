# frozen_string_literal: true

module Api
  module Actions
    module Users
      module Lock
        class Create
          include Api::Action

          security_level 3

          class Params < Hanami::Action::Params
            predicates NamePredicates
            messages :i18n

            params do
              required(:user_id).filled(:str?, :name?, max_size?: 255)
            end
          end

          def initialize(provider_repository: ProviderRepository.new,
                         **opts)
            super
            @provider_repository ||= provider_repository
          end

          def handle(_request, _response)
            halt_json 400, errors: [params.errors] unless params.valid?

            result = call_interacttor(ProviderLockUser.new(provider_repository: @provider_repository),
                                      {username: params[:user_id]})

            providers = result.providers.compact.transform_values { |v| {locked: !!v} }
            self.status = 200
            self.body = generate_json({providers: providers})
          end
        end
      end
    end
  end
end
