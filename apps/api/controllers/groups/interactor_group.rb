# frozen_string_literal: true

module Api
  module Controllers
    module Groups
      module InteractorGroup
        def initialize(provider_repository: ProviderRepository.new,
                       group_repository: GroupRepository.new,
                       **opts)

          super
          @provider_repository ||= provider_repository
          @group_repository ||= group_repository
        end

        private def sync_group(params)
          @sync_group ||= SyncGroup.new(provider_repository: @provider_repository,
                                        group_repository: @group_repository)
          result = @sync_group.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        # TODO: 未実装
        # private def provider_create_group(params)
        #   @provider_create_group ||= CreateGroup.new(provider_repository: @provider_repository)
        #   result = @provider_create_group.call(params)
        #   halt_json 500, errors: result.errors if result.failure?

        #   result
        # end

        private def provider_read_group(params)
          @provider_read_group ||= ProviderReadGroup.new(provider_repository: @provider_repository)
          result = @provider_read_group.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        # TODO: 未実装
        # private def provider_update_group(params)
        #   @provider_update_group ||= UpdateGroup.new(provider_repository: @provider_repository)
        #   result = @provider_update_group.call(params)
        #   halt_json 500, errors: result.errors if result.failure?

        #   result
        # end

        # TODO: 未実装
        # private def provider_delete_group(params)
        #   @provider_delete_group ||= DeleteGroup.new(provider_repository: @provider_repository)
        #   result = @provider_delete_group.call(params)
        #   halt_json 500, errors: result.errors if result.failure?

        #   result
        # end
      end
    end
  end
end
