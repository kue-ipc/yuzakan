# frozen_string_literal: true

require_relative './provider_group'

module Api
  module Controllers
    module Groups
      module EntityGroup
        include ProviderGroup

        def initialize(group_repository: GroupRepository.new,
                       **opts)
          super
          @group_repository ||= group_repository
        end

        private def load_group
          if @sync
            result = sync_group({groupname: @name})
            @group = result.group
            @data = result.data
            @providers = result.providers
          else
            @group = @group_repository.find_by_name(@name)
            @date = nil
            @providers = nil
          end
        end

        private def group_json
          hash = convert_for_json(@group, assoc: true).dup
          hash[:data] = @data unless @data.nil?
          hash[:providers] = @providers unless @providers.nil?
          generate_json(hash)
        end
      end
    end
  end
end
