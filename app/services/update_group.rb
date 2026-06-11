# frozen_string_literal: true

module Yuzakan
  module Services
    class UpdateGroup < Yuzakan::ServiceOperation
      category :group

      def call(serivec, groupname, **params)
        return unless can_call_any?(services, :group_update)

        groupname = step validate_name(groupname)
        adapter = step get_adapter(service)
        groupdata = step map_data(service, params)
        new_groupdata = adapter.group_update(groupname, groupdata)
        return unless new_groupdata

        new_params = step convert_data(service, new_groupdata)
        cache_write(service, groupname) { new_params }
        new_params
      end
    end
  end
end
