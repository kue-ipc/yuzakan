# frozen_string_literal: true

module API
  module Actions
    module Groups
      module InteractorGroup
        def initialize(provider_repository: ProviderRepository.new,
                       group_repository: GroupRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
          @group_repository ||= group_repository
        end

        private def call_interacttor(interactor, params)
          result = interactor.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def sync_group(params)
          @sync_group ||= SyncGroup.new(provider_repository: @provider_repository,
                                        group_repository: @group_repository)
          call_interacttor(@sync_group, params)
        end

        # TODO: 未実装
        # private def provider_create_group(params)
        #   @provider_create_group ||= ProviderCreateGroup.new(provider_repository: @provider_repository)
        #   call_interacttor(@provider_create_group, params)
        # end

        private def provider_read_group(params)
          @provider_read_group ||= ProviderReadGroup.new(provider_repository: @provider_repository)
          call_interacttor(@provider_read_group, params)
        end

        # TODO: 未実装
        # private def provider_update_group(params)
        #   @provider_update_group ||= ProviderUpdateGroup.new(provider_repository: @provider_repository)
        #   call_interacttor(@provider_update_group, params)
        # end

        # TODO: 未実装
        # private def provider_delete_group(params)
        #   @provider_delete_group ||= ProviderDeleteGroup.new(provider_repository: @provider_repository)
        #   call_interacttor(@provider_delete_group, params)
        # end
      end
    end
  end
end
