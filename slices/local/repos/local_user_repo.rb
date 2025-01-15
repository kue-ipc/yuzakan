# frozen_string_literal: true

module Local
  module Repos
    class LocalUserRepo < Local::DB::Repo
      commands :create, :update, :delete

      def get(name)
        pp self.class
        pp self.class.root
        pp self.root
        local_users.by_name(name).one
      end

      def set(name, **)
        update(name, {**}) || create({name: name, **})
      end

      def unset(name)
        delete(name)
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
        end.pluck(:name)
      end
    end
  end
end
