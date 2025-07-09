# frozen_string_literal: true

module API
  module Actions
    module Groups
      module InteractorGroup
        def initialize(service_repository: ServiceRepository.new,
          group_repository: GroupRepository.new,
          **opts)
          super
          @service_repository ||= service_repository
          @group_repository ||= group_repository
        end

        private def call_interacttor(interactor, params)
          result = interactor.call(params)
          halt_json 500, errors: result.errors if result.failure?

          result
        end

        private def sync_group(params)
          @sync_group ||= SyncGroup.new(service_repository: @service_repository,
            group_repository: @group_repository)
          call_interacttor(@sync_group, params)
        end

        # TODO: 未実装
        # private def service_create_group(params)
        #   @service_create_group ||= ServiceCreateGroup.new(service_repository: @service_repository)
        #   call_interacttor(@service_create_group, params)
        # end

        private def service_read_group(params)
          @service_read_group ||= ServiceReadGroup.new(service_repository: @service_repository)
          call_interacttor(@service_read_group, params)
        end

        # TODO: 未実装
        # private def service_update_group(params)
        #   @service_update_group ||= ServiceUpdateGroup.new(service_repository: @service_repository)
        #   call_interacttor(@service_update_group, params)
        # end

        # TODO: 未実装
        # private def service_delete_group(params)
        #   @service_delete_group ||= ServiceDeleteGroup.new(service_repository: @service_repository)
        #   call_interacttor(@service_delete_group, params)
        # end
      end
    end
  end
end
