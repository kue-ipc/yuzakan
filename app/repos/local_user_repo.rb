# frozen_string_literal: true

module Yuzakan
  module Repos
    class LocalUserRepo < Yuzakan::DB::Repo
      def get(name)
        providers.by_name(name).one
      end

      def set(name, **)
        providers.by_name(name).changeset(:update, **).map(:touch).commit ||
          providers.changeset(:create, **, name: name).map(:add_timestamps)
            .commit
      end

      def unset(name)
        providers.by_name(name).changeset(:delete).commit
      end

      def all
        providers.to_a
      end

      def by_username(username)
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
