# frozen_string_literal: true

require_relative './interactor_group'

module Api
  module Controllers
    module Groups
      module EntityGroup
        include InteractorGroup

        def initialize(group_repository: GroupRepository.new,
                       **opts)
          super
          @group_repository ||= group_repository
        end

        private def load_group(sync: false)
          if sync
            result = sync_group({groupname: @name})
            @group = result.group
            @providers = result.providers
          else
            @group = @group_repository.find_by_name(@name)
            @date = nil
            @providers = nil
          end
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
