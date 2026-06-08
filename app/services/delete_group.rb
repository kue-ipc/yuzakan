# frozen_string_literal: true

module Yuzakan
  module Services
    class DeleteGroup < Yuzakan::ServiceOperation
      category :group

      def call(groupname, services = nil)
        groupname = step validate_name(groupname)
        services = step get_services(services, method: :group_delete)

        services.to_h do |service|
          adapter = step get_adapter(service)
          groupdata = adapter.delete_group(groupname)
          result =
            if groupdata
              cache_delete(service) # delete list
              cache_delete(service, groupname)
              step convert_data(service, groupdata)
            end
          [service.name, result]
        end.compact
      end
    end
  end
end
