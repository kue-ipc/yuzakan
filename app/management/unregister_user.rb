# frozen_string_literal: true

# Userレポジトリからの解除
module Yuzakan
  module Management
    class UnregisterUser < Yuzakan::Operation
      include Deps[
        "repos.user_repo",
        "repos.managed_user_repo",
      ]

      def call(username, time: Time.now)
        username = step validate_name(username)
        step unregister(username, time:)
      end

      def unregister(username, time: Time.now)
        user = user_repo.get(username)
        return Success(nil) if user.nil?

        user_repo.transaction do
          managed_users.clear_for_user(user)
          if user.deleted_at
            Success(user_repo.set(username, synced_at: time))
          else
            Success(user_repo.set(username, deleted_at: time, synced_at: time))
          end
        end
      end
    end
  end
end
