# frozen_string_literal: true

module User
  module Actions
    module Password
      class Edit < User::Action
        expose :excluded_providers

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
          @excluded_providers = ProviderRepository.new.all_individual_password
        end
      end
    end
  end
end
