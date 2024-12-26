# frozen_string_literal: true

module Yuzakan
  module Repos
    class LocalUserRepo < Yuzakan::DB::Repo
      def get(name)
        local_users.by_name(name).one
      end

      def set(name, **)
        local_users.by_name(name).changeset(:update, **).map(:touch).commit ||
          local_users.changeset(:create, **, name: name).map(:add_timestamps)
            .commit
      end

      def unset(name)
        local_users.by_name(name).changeset(:delete).commit
      end

      def exist?(name)
        local_users.exist?(name:)
      end

      def list
        local_users.pluck(:name)
      end

      def all
        local_users.to_a
      end

      def search(query, ignore_case: true, **)
        pattern = generate_like_pattern(query, **)
        local_users.where do
          if ignore_case
            name.ilike(pattern) | display_name.ilike(pattern) |
              email.ilike(pattern)
          else
            name.like(pattern) | display_name.like(pattern) |
              email.like(pattern)
          end
        end
      end.pluck(:name)
    end
  end
end
