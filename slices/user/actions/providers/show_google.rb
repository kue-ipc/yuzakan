# frozen_string_literal: true

require "hanami/action/cache"

module User
  module Actions
    module Providers
      class Show < User::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :google_provider
        expose :google_user
        expose :creatable

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
          @google_provider = ProviderRepository.new.first_google_with_adapter
          @google_user = @google_provider.read(current_user.name)

          @creatable = false
          return if @google_user

          # FIXME: UserAttrsを使わずに、Providers::ReadUserを使用すること。
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
