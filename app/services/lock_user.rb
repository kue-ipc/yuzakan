# frozen_string_literal: true

require "hanami/validations"
require_relative "../provider_interactor"

module Yuzakan
  module Providers
    class LockUser < Yuzakan::ProviderOperation
      class Validator
        include Hanami::Validations
        predicates NamePredicates
        messages :i18n

        validations do
          required(:username).filled(:str?, :name?, max_size?: 255)
          optional(:providers).each(:str?, :name?, max_size?: 255)
        end
      end

      def call(params)
        username = params[:username]

        call_providers(params[:providers], operation: :user_lock) do |provider|
          provider.user_lock(username)
        end
      end

      def user_lock(username)
        need_adapter!
        need_mappings!

        @adapter.user_lock(username).tap do |result|
          @cache_store.delete(user_key(username)) if result
        end
      end
    end
  end
end
