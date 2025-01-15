# frozen_string_literal: true

module Local
  module Repos
    class LocalGroupRepo < Local::DB::Repo
      commands :create, update: :by_name, delete: :by_name

      def all
        local_groups.to_a
      end

      def find(name)
        local_groups.by_name(name).one
      end

      def first
        local_groups.first
      end

      def last
        local_groups.last
      end

      def clear
        local_groups.clear
      end

      def get(name)
      end

      def set(name, **)
        update(name, {**}) || create({name: name, **})
      end

      def unset(name)
        delete(name)
      end

      def exist?(name)
        local_groups.exist?(name:)
      end

      def list
        local_groups.pluck(:name)
      end

      def search(query, ignore_case: true, **)
        pattern = generate_like_pattern(query, **)
        local_groups.where do
          if ignore_case
            name.ilike(pattern) | display_name.ilike(pattern)
          else
            name.like(pattern) | display_name.like(pattern)
          end
        end.pluck(:name)
      end

      def list_of_user(user)
        local_groups.assoc(:users).where(name: user.name)
      end

      def by_username(_name)
        local_groups.where(username: username)
      end

      def find_by_username(username)
        by_username(username).first
      end

      def ilike(pattern)
        local_groups.where do
          username.ilike(pattern) | display_name.ilike(pattern) | email.ilike(pattern)
        end
      end
    end
  end
end
