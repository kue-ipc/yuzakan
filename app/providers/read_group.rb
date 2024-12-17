# frozen_string_literal: true

module Yuzakan
  module Providers
    class ReadGroup < Yuzakan::Operation
      include Deps["repos.provider_repo"]

      def call(groupname, provider_names = nil)
        groupname = step validate_name(groupname)

        providers = get_providers(provider_names)

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

      private def get_providers(provider_names = nil)
        if provider_names
          provider_names.map do |provider_name|
            provider_repo.find_with_adapter_by_name(provider_name)
          end.compact
        else
          provider_repo.ordered_all_with_adapter_by_operation(:group_read)
        end
      end
    end
  end
end
