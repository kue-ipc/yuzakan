# frozen_string_literal: true

# TODO: 見直し必要

module Yuzakan
  module Services
    class SearchGrup < Yuzakan::ServiceOperation
      category :user

      def call(username, password, services = nil)
        username = step validate_name(username)
        password = step validate_password(password)
        services = step get_services(services, method: :user_auth)
        step authenticate(username, password, services)
      end

      private def authenticate(username, password, services)
        services.each do |service|
          adapter = step get_adapter(service)
          return Success(service) if adapter.user_auth(username, password)
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
