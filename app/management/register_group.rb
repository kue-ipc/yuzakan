# frozen_string_literal: true

# Groupレポジトリへの登録または更新
module Yuzakan
  module Management
    class RegisterGroup < Yuzakan::Operation
      include Deps[
        "repos.group_repo",
      ]

      def call(groupname, params)
        groupname = step validate_name(groupname)
        params = step validate_params(params)
        step register(groupname, params)
      end

      private def validate_params(params)
        Success({
          **params.slice(:display_name, :basic),
          deleted: false,
          deleted_at: nil,
        })
      end

      private def register(groupname, params)
        Success(group_repo.set(groupname, **params))
      end
    end
  end
end
