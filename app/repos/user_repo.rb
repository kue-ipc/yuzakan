# frozen_string_literal: true

module Yuzakan
  module Repos
    class UserRepo < Yuzakan::DB::Repo
      private def by_name(name) = users.by_name(normalize_name(name))

      def get(name) = by_name(name).one

      def set(name, **)
        by_name(name).changeset(:update, **).map(:touch).commit ||
          users.changeset(:create, **, name: normalize_name(name))
            .map(:add_timestamps).commit
      end

      def unset(name) = by_name(name).changeset(:delete).commit

      def exist?(name) = by_name(name).exist?

      def all = users.to_a

      def list = users.pluck(:name)

      def get_with_groups(name)
        by_name(name).combine(:group, members: :group).one
      end

      # TODO: ここらは下は未整理

      def ordered_filter(order: {name: :asc}, filter: {})
        order = {name: :asc} if order.nil? || order.empty?

        order_attributes = order.map { |key, value|
          case value.downcase.intern
          when :asc
            users[key].qualified.asc
          when :desc
            users[key].qualified.desc
          end
        }.compact

        filter(**filter).order(*order_attributes)
      end

      def filter(query: nil, match: :partial, prohibited: nil, deleted: nil)
        q = search(query: query, match: match)
        q = q.where(prohibited: prohibited) unless prohibited.nil?
        case deleted
        when true, false
          q = q.where(deleted: deleted)
        when Range
          q = q.where(deleted: true).where(deleted_at: deleted)
        end
        q
      end

      def search(query: nil, match: :partial)
        return users if query.nil? || query.empty?

        sql_query =
          case match
          when :extract
            query
          when :forward
            "#{query}%"
          when :backward
            "%#{query}"
          when :partial
            "%#{query}%"
          end
        users.where { name.ilike(sql_query) | display_name.ilike(sql_query) }
      end

      private def by_name(name)
        users.where(name: name)
      end

      def all_by_name(name)
        by_name(name).to_a
      end

      def find_by_name(name)
        by_name(name).one
      end

      # with groups

      def all_with_groups
        aggregate(members: :group).map_to(User).to_a
      end

      def find_with_groups(id)
        aggregate(members: :group).where(id: id).map_to(User).one
      end

      private def with_groups_by_name(name)
        aggregate(members: :group).where(name: name).map_to(User)
      end

      def all_with_groups_by_name(name)
        with_groups_by_name(name).to_a
      end

      def find_with_groups_by_name(name)
        with_groups_by_name(name).one
      end
    end
  end
end
