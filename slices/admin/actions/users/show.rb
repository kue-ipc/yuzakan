# frozen_string_literal: true

module Admin
  module Actions
    module Users
      class Show < Admin::Action
        contract Validation::IdContract

        def initialize(user_repository: UserRepository.new, **opts)
          super
          @user_repository ||= user_repository
        end

        def handle(_request, _response)
          halt 400 unless params.valid?
        end
      end
    end
  end
end
