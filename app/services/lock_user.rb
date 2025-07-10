# frozen_string_literal: true

require "hanami/validations"
require_relative "../service_interactor"

module Yuzakan
  module Services
    class LockUser < Yuzakan::ServiceOperation
      class Validator
        include Hanami::Validations
        predicates NamePredicates
        messages :i18n

        validations do
          required(:username).filled(:name, max_size?: 255)
          optional(:services).each(:name, max_size?: 255)
        end
      end

      def call(params)
        username = params[:username]

        call_services(params[:services], operation: :user_lock) do |service|
          service.user_lock(username)
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
