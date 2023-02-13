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

        private def load_group(groupname: @groupname, sync: @sync)
          if sync
            result = provider_sync_group({groupname: groupname})
            @group = result.group
            @groupdata = result.groupdata
            @providers = result.providers
          else
            @group = @group_repository.find_by_groupname(groupname)
            @groupdate = nil
            @providers = nil
          end
          {
            group: @group,
            groupdata: @groupdate,
            providers: @providers,
          }
        end

        private def group_data(group: @group, groupdata: @gorupdata, providers: @providers)
          {
            **convert_for_json(group, assoc: true),
            groupdata: groupdata,
            providers: providers&.compact&.to_a,
          }
        end

        private def group_json(**opts)
          generate_json(group_data(**opts))
        end
      end
    end
  end
end
