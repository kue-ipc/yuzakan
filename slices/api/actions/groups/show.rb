# frozen_string_literal: true

module API
  module Actions
    module Groups
      class Show < API::Action
        include Deps[
          "repos.service_repo",
          "repos.group_repo"
        ]

        security_level 2

        params do
          required(:id).filled(:name, max_size?: 255)
        end

        def handle(request, response) # rubocop:disable Lint/UnusedMethodArgument
          halt_json 400, errors: [params.errors] unless params.valid?

          @name = params[:id]
          load_group

          halt_json 404 if @group.nil?
          self.body = group_json
        end

        private def load_group
          result = sync_group({groupname: @name})
          @group = result.group
          @services = result.services
        end

        private def group_json(**data)
          hash = convert_for_json(@group, assoc: true).dup
          hash[:services] = @services unless @services.nil?
          hash.merge!(data)
          generate_json(hash)
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
