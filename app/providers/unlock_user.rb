# frozen_string_literal: true

require "hanami/validations"
require_relative "../provider_interactor"
module Yuzakan
  module Providers
    class UnlockUser < Yuzakan::ProviderOperation
      class Validator
        include Hanami::Validations
        predicates NamePredicates
        messages :i18n

        validations do
          required(:username).filled(:str?, :name?, max_size?: 255)
          optional(:password).filled(:str?, max_size?: 255)
          optional(:providers).each(:str?, :name?, max_size?: 255)
        end
      end

      def call(params)
        username = params[:username]
        password = params[:password]

        call_providers(params[:providers],
          operation: :user_unlock) do |provider|
          provider.user_unlock(username, password)
        end
      end

      def user_unlock(username, password = nil)
        need_adapter!

        @adapter.user_unlock(username, password).tap do |result|
          @cache_store.delete(user_key(username)) if result
        end
      end
    end
  end
end
