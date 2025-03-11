# frozen_string_literal: true

module Local
  module Repos
    class LocalUserRepo < Local::DB::Repo
      commands :create
      def all = local_users.to_a
      def first = local_users.first
      def last = local_users.last
      def clear = local_users.clear

      # id (pk)
      commands update: :by_pk, delete: :by_pk
      def ids = local_users.pluck(:id)
      private def by_id(id) = local_users.by_pk(id)
      def find(id) = by_id(id).one
      def exist?(id) = by_id(id).exist?

      # name
      private def by_name(name) = local_users.by_name(name)
      def update_by_name(name, **) = by_name(name).command(:update).call(**)
      def delete_by_name(name) = by_name(name).command(:delete).call
      def find_by_name(name) = by_name(name).one
      def exist_by_name?(name) = by_name(name).exist?
      def names = local.users.pluck(:name)

      # search
      private def search(query, ignore_case: true, **)
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
      end
      def search_all(...) = search(...).to_a
      def search_ids(...) = search(...).pluck(:id)
      def search_names(...) = search(...).pluck(:name)

      def find_with_groups_by_name(name)
        by_name(name).combine(:local_groups).combine(:local_member_groups).one
      end

      def create_with_members(**)
        local_users.combine(:local_members).command(:create).call(**)
      end
    end
  end
end
