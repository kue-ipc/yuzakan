# frozen_string_literal: true

module Web
  module Controllers
    module User
      module Password
        class Edit
          include Web::Action

          expose :excluded_providers

          def call(params) # rubocop:disable Lint/UnusedMethodArgument
            @excluded_providers = ProviderRepository.new.all_individual_password
          end
        end
      end
    end
  end
end
