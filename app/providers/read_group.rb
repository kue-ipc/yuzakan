# frozen_string_literal: true

module Yuzakan
  module Providers
    class ReadGroup < Yuzakan::Operation
      include Deps[
        "repos.provider_repo",
        "providers.get_adapter",
        "providers.convert_data",
        "cache_store",
      ]

      def call(groupname, providers = nil)
        groupname = step validate_name(groupname)
        providers = step get_providers(providers)

        providers.to_h do |provider|
          data = step read_group(provider, groupname)
          [provider.name, data]
        end

        @providers = get_providers(params[:providers]).to_h do |provider|
          [provider.name, provider.group_read(groupname)]
        rescue => e
          Hanami.logger.error "[#{self.class.name}] Failed on #{provider.name} for #{groupname}"
          Hanami.logger.error e
          error(I18n.t("errors.action.error", action: I18n.t("interactors.provider_read_group"),
            target: provider.label))
          error(e.message)
          fail!
        end
      end

      private def valid?(params)
        result = Validator.new(params).validate
        if result.failure?
          Hanami.logger.error "[#{self.class.name}] Validation failed: #{result.messages}"
          error(result.messages)
          return false
        end

        true
      end

      private def get_providers(providers = nil)
        providers =
          case providers
          in nil
            provider_repo.ordered_all_with_adapter_by_operation(:group_read)
          in []
            []
          in [String | Symbol, *]
            providers.map { |provider| provider_repo.get(provider) }.compact
          in [Yuzakann::Struct::Provider, *]
            providers
          else
            Failure(:invalid_provider_list)
          end
        Success(providers)
      end

      private def read_group(provider, groupname)
        return nil unless provider.group

        name = "provider:#{provider.name}:group:#{groupname}"
        data = cache_store.fetch(name) do
          provider_adapter = step get_adatper.call(provider)
          raw_data = provider_adapter.group_read(groupname)
          step convert_data(provider, raw_data, type: :group)
        end
        Success(data)
      end
    end
  end
end
