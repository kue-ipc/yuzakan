# frozen_string_literal: true

module Yuzakan
  module Services
    class ReadGroup < Yuzakan::ServiceOperation
      include Deps["services.list_group"]

      category :group

      def call(service, groupname)
        return unless can_call?(service, :group_read)

        groupname = step validate_name(groupname)
        list = step list_group.call(service)
        return unless list.include?(groupname)

        cache_fetch(service, groupname) do
          adapter = step get_adapter(service)
          groupdata = adapter.group_read(groupname)
          step convert_data(service, groupdata)
        end
      end
    end
  end
end
