# frozen_string_literal: true

require_relative "interactor_group"

module Api
  module Controllers
    module Groups
      module EntityGroup
        include InteractorGroup

        private def load_group
          result = sync_group({groupname: @name})
          @group = result.group
          @providers = result.providers
        end

        private def group_json(**data)
          hash = convert_for_json(@group, assoc: true).dup
          hash[:providers] = @providers unless @providers.nil?
          hash.merge!(data)
          generate_json(hash)
        end
      end
    end
  end
end
