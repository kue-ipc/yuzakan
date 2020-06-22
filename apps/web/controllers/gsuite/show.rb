# frozen_string_literal: true

module Web
  module Controllers
    module Gsuite
      class Show
        include Web::Action

        expose :gsuite_user

        def call(_params)
          gsuite_repository = ProviderRepository.new.first_gsuite_with_params
          @gsuite_user = gsuite_repository.adapter.read(current_user.name)
        end
      end
    end
  end
end
