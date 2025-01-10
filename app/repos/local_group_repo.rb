# frozen_string_literal: true

module Yuzakan
  module Repos
    class LocalGroupRepo < Yuzakan::DB::Repo
      commands :create, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}}
      commands update: :by_name, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}}
      commands delete: :by_name
      private :create, :update, :delete

      def get(name)
        local_groups.by_name(name).one
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

      def all
        local_groups.to_a
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

      def by_username(name)
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
