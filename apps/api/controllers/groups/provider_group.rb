# frozen_string_literal: true

module Api
  module Controllers
    module Groups
      module ProviderGroup
        def initialize(provider_repository: ProviderRepository.new,
                       group_repository: GroupRepository.new,
                       **opts)

          super
          @provider_repository ||= provider_repository
          @group_repository ||= group_repository
        end

        private def provider_sync_group(params)
          @provider_sync_group ||= SyncGroup.new(provider_repository: @provider_repository,
                                                 group_repository: @group_repository)
          result = @provider_sync_group.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        # TODO: 今は未実装
        # private def create_group(params)
        #   @create_group ||= CreateGroup.new(provider_repository: @provider_repository)
        #   result = @create_group.call(params)
        #   halt_json 500, errors: result.errors if result.failure?

        #   result
        # end

        private def provider_read_group(params)
          @provider_read_group ||= ProviderReadGroup.new(provider_repository: @provider_repository)
          result = @provider_read_group.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        # TODO: 今は未実装
        # private def update_group(params)
        #   @update_group ||= UpdateGroup.new(provider_repository: @provider_repository)
        #   result = @update_group.call(params)
        #   halt_json 500, errors: result.errors if result.failure?

        #   result
        # end

        # TODO: 今は未実装
        # private def delete_group(params)
        #   @delete_group ||= DeleteGroup.new(provider_repository: @provider_repository)
        #   result = @delete_group.call(params)
        #   halt_json 500, errors: result.errors if result.failure?

        #   result
        # end
      end
    end
  end
end
