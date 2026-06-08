# frozen_string_literal: true

module Yuzakan
  module Services
    class UpdateGroup < Yuzakan::ServiceOperation
      category :group

      def call(groupname, services = nil, **params)
        groupname = step validate_name(groupname)
        services = step get_services(services, method: :group_update)

        services.to_h do |service|
          adapter = step get_adapter(service)
          groupdata = step map_data(service, params)
          new_groupdata = adapter.group_update(groupname, groupdata)
          result =
            if new_groupdata
              new_params = step convert_data(service, new_groupdata)
              cache_delete(service) # delete list
              cache_write(service, groupname) { new_params }
              new_params
            end
          [service.name, result]
        end.compact
      end
    end
  end
end
