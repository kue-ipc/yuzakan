# frozen_string_literal: true

module Yuzakan
  module Repos
    class GroupRepo < Yuzakan::DB::Repo
      private def by_name(name) = groups.by_name(normalize_name(name))

      def get(name) = by_name(name).one

      def set(name, **)
        by_name(name).changeset(:update, **).map(:touch).commit ||
          groups.changeset(:create, **, name: normalize_name(name))
            .map(:add_timestamps).commit
      end

      def unset(name) = by_name(name).changeset(:delete).commit

      def exist?(name) = by_name(name).exist?

      def all = groups.to_a

      def list = groups.pluck(:name)

      # TODO: ここらは下は未整理

      def ordered_all
        groups.order(:name).to_a
      end

      def ordered_filter(order: {name: :asc}, filter: {})
        order = {name: :asc} if order.nil? || order.empty?

        order_attributes = order.map do |key, value|
          case value.downcase.intern
          when :asc
            groups[key].qualified.asc
          when :desc
            groups[key].qualified.desc
          end
        end.compact

        filter(**filter).order(*order_attributes)
      end

      def filter(query: nil, match: :partial, primary: nil, prohibited: nil,
        deleted: nil)
        q = search(query: query, match: match)
        q = q.where(primary: primary) unless primary.nil?
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
        return groups if query.nil? || query.empty?

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
        groups.where { name.ilike(sql_query) | display_name.ilike(sql_query) }
      end

      private def by_name(name)
        groups.where(name: name)
      end

      def all_by_name(name)
        by_name(name).to_a
      end

      def find_by_name(name)
        by_name(name).one
      end

      def find_or_create_by_name(name)
        find_by_name(name) || create({name: name})
      end

      def add_user(group, user)
        member = member_for(group, user)
        return if member

        assoc(:members, group).add(user_id: user.id)
      end

      def remove_user(group, user)
        member = member_for(group, user)
        return unless member

        assoc(:members, group).remove(member.id)
      end

      private def member_for(group, user)
        assoc(:members, group).where(user_id: user.id).to_a.first
      end

      def clear_user(group)
        assoc(:members, group).delete
      end
    end
  end
end
