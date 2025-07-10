# frozen_string_literal: true

module Admin
  module Actions
    module Users
      class Show < Admin::Action
        params do
          required(:id).filled(:name_or_symbol, max_size?: 255)
        end

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
