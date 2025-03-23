# frozen_string_literal: true

module Local
  module Repos
    class LocalGroupRepo < Local::DB::Repo
      commands :create
      def all = local_groups.to_a
      def first = local_groups.first
      def last = local_groups.last
      def clear = local_groups.delete

      # id (pk)
      commands update: :by_pk, delete: :by_pk
      def ids = local_groups.pluck(:id)
      private def by_id(id) = local_groups.by_pk(id)
      def find(id) = by_id(id).one
      def exist?(id) = by_id(id).exist?

      # name
      private def by_name(name) = local_groups.by_name(name)
      def update_by_name(name, **) = by_name(name).command(:update).call(**)
      def delete_by_name(name) = by_name(name).command(:delete).call
      def find_by_name(name) = by_name(name).one
      def exist_by_name?(name) = by_name(name).exist?
      def names = local.groups.pluck(:name)

      def all_by_names(*names) = local_groups.where(name: names.flatten).to_a

      # search
      private def search(query, ignore_case: true, **)
        pattern = generate_like_pattern(query, **)
        local_groups.where do
          if ignore_case
            name.ilike(pattern) | display_name.ilike(pattern)
          else
            name.like(pattern) | display_name.like(pattern)
          end
        end
      end
      def search_all(...) = search(...).to_a
      def search_ids(...) = search(...).pluck(:id)
      def search_names(...) = search(...).pluck(:name)

      def find_with_users_by_name(name)
        by_name(name).combine(:local_users).combine(:local_member_users).one
      end

      def find_with_members(id)
        by_pk(id).combine(:local_members).one
      end
    end
  end
end
