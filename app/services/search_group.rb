# frozen_string_literal: true

# TODO: 見直し必要

module Yuzakan
  module Providers
    class SearchGrup < Yuzakan::ProviderOperation
      category :user

      def call(username, password, providers = nil)
        username = step validate_name(username)
        password = step validate_password(password)
        providers = step get_providers(providers, method: :user_auth)
        step authenticate(username, password, providers)
      end

      private def authenticate(username, password, providers)
        providers.each do |provider|
          adapter = step get_adapter(provider)
          return Success(provider) if adapter.user_auth(username, password)
        rescue => e
          return Failure([:error, e])
        end

        Failure([:failure, t("errors.wrong_username_or_password")])
      end
    end

          def user_list
        need_adapter!
        @cache_store.fetch(user_list_key) do
          @cache_store[user_list_key] = @adapter.user_list
        end
      end

            def user_search(query)
        need_adapter!
        @cache_store.fetch(user_search_key(query)) do
          @cache_store[user_search_key(query)] = @adapter.user_search(query)
        end
      end

      def group_list
        need_adapter!
        need_group!
        @cache_store.fetch(group_list_key) do
          @cache_store[group_list_key] = @adapter.group_list
        end
      end

      def group_search(query)
        need_adapter!
        need_group!
        @cache_store.fetch(group_search_key(query)) do
          @cache_store[group_search_key(query)] = @adapter.group_search(query)
        end
      end


  end
end
