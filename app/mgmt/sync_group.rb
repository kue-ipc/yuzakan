# frozen_string_literal: true

# Groupレポジトリと各プロバイダーのグループ情報を同期し、グループを返す。
module Yuzakan
  module Mgmt
    class SyncGroup < Yuzakan::Operation
      include Deps[
        "providers.read_group",
        "mgmt.register_group",
        "mgmt.unregister_group",
      ]

      def call(groupname)
        groupname = step validate_name(groupname)
        params = step read_group(groupname)
        step sync_group(groupname, params)
      end

      private def read_group(groupname)
        providers = read_group.call(groupname)
          .value_or { |failure| return Failure(failure) }
        return Success(nil) if providers.empty?

        params = {primary: false}
        providers.each_value do |data|
          [:display_name, :primary].each do |name|
            params[name] ||= data[name] if data.key?(name)
          end
        end
        Success(params)
      end

      private def sync_group(groupname, params)
        if params
          register_group.call(groupname, params)
        else
          unregister_group.call(groupname)
        end
      end
    end
  end
end
