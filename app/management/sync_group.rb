# frozen_string_literal: true

# Groupレポジトリと各プロバイダーのグループ情報を同期し、グループを返す。
module Yuzakan
  module Management
    class SyncGroup < Yuzakan::Operation
      include Deps[
        "providers.read_group",
        "management.register_group",
        "management.unregister_group"
      ]

      def call(groupname)
        groupname = step validate_name(groupname)
        params = step read(groupname)
        step sync(groupname, params)
      end

      private def read(groupname)
        providers = read_group.call(groupname)
          .value_or { return Failure(_1) }
        return Success(nil) if providers.empty?

        params = {basic: false}
        providers.each_value do |data|
          [:label, :basic].each do |name|
            params[name] ||= data[name] if data.key?(name)
          end
        end
        Success(params)
      end

      private def sync(groupname, params)
        if params
          register_group.call(groupname, params)
        else
          unregister_group.call(groupname)
        end
      end
    end
  end
end
