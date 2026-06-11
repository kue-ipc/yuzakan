# frozen_string_literal: true

module Yuzakan
  module Services
    class CreateGroup < Yuzakan::ServiceOperation
      category :group

      def call(service, groupname, **params)
        return unless can_call?(service, :group_create)

        groupname = step validate_name(groupname)
        adapter = step get_adapter(service)
        groupdata = step map_data(service, params)
        new_groupdata = adapter.group_create(groupname, groupdata)
        return unless new_groupdata

        cache_delete(service) # delete list
        new_params = step convert_data(service, new_groupdata)
        cache_write(service, groupname) { new_params }
        new_params
      end
    end
  end
end
