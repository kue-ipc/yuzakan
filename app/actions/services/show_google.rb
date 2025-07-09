# frozen_string_literal: true

require "hanami/action/cache"

module Yuzakan
  module Actions
    module Services
      class Show < Yuzakan::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :google_service
        expose :google_user
        expose :creatable

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          @google_service = ServiceRepository.new.first_google_with_adapter
          @google_user = @google_service.read(current_user.name)

          @creatable = false
          return if @google_user

          # FIXME: UserAttrsを使わずに、Services::ReadUserを使用すること。
          result = UserAttrs.new.call(username: current_user.name)
          if result.successful? &&
              ["学生", "教員", "職員"].include?(result.attrs[:affiliation])
            @creatable = true
          end
        end
      end
    end
  end
end
