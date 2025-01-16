# frozen_string_literal: true

# Userレポジトリからの解除
module Yuzakan
  module Mgmt
    class UnregisterUser < Yuzakan::Operation
      include Deps[
        "repos.user_repo",
        "repos.member_repo"
      ]

      def call(username)
        username = step validate_name(username)
        step unregister_user(username)
      end

      def unregister_user(username)
        user = user_repo.get(username)
        return Success(nil) if user.nil?
        return Success(user) if user.deleted?

        user_repo.transaction do
          member_repo.delete_by_user(user)
          Success(user_repo.set(username, deleted: true, deleted_at: Time.now))
        end
      end
    end
  end
end
