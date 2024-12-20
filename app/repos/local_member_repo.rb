# frozen_string_literal: true

module Yuzakan
  module Repos
    class LocalUserRepo < Yuzakan::DB::Repo
      def get(name)
      end
      def by_name(username)
        local_users.where(username: username)
      end

      def find_by_username(username)
        by_username(username).first
      end

      def ilike(pattern)
        local_users.where do
          username.ilike(pattern) | display_name.ilike(pattern) | email.ilike(pattern)
        end
      end
    end
  end
end
