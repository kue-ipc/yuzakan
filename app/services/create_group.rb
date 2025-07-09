# frozen_string_literal: true

module Yuzakan
  module Services
    class CreateGroup < Yuzakan::ServiceOperation
      category :group

      def call(groupname, services = nil, **params)
        groupname = step validate_name(groupname)
        services = step get_services(services, method: :group_create)

        # TODO: 途中で失敗した場合の処理
        services.to_h do |service|
          adapter = step get_adapter(service)
          groupdata = step map_data(service, params)
          new_groupdata = adapter.group_create(groupname, groupdata)
          result =
            if new_groupdata
              new_params = step convert_data(service, new_groupdata)
              cache_delete(service)
              cache_write(service, groupname) { new_params }
              new_params
            end
          [service.name, result]
        end
      end
    end
  end
end
