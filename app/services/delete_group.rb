# frozen_string_literal: true

module Yuzakan
  module Services
    class DeleteGroup < Yuzakan::ServiceOperation
      category :group

      def call(service, groupname)
        return unless can_call?(service, :group_delete)

        groupname = step validate_name(groupname)
        adapter = step get_adapter(service)
        groupdata = adapter.delete_group(groupname)
        return unless groupdata

        cache_delete(service) # delete list
        cache_delete(service, groupname)
        step convert_data(service, groupdata)
      end
    end
  end
end
