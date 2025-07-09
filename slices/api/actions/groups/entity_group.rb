# frozen_string_literal: true

require_relative "interactor_group"

module API
  module Actions
    module Groups
      module EntityGroup
        include InteractorGroup

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
      end
    end
  end
end
