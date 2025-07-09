# frozen_string_literal: true

module Yuzakan
  module Services
    class ReadGroup < Yuzakan::ServiceOperation
      category :group

      def call(groupname, services = nil)
        groupname = step validate_name(groupname)
        services = step get_services(services, method: :group_read)

        # TODO: 途中で失敗した場合の処理
        services.to_h do |service|
          result =
            cache_fetch(service, groupname) do
              adapter = step get_adapter(service)
              groupdata = adapter.group_read(groupname)
              step convert_data(service, groupdata)
            end
          [service.name, result]
        end.compact
      end
    end
  end
end
