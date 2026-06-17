# frozen_string_literal: true

require "hanami/db/repo"

module Yuzakan
  module DB
    class NameRepo < Yuzakan::DB::Repo
      # common interface
      private def by_name(name) = root.by_name(name)
      def get(name) = by_name(name).one
      def get!(name) = by_name(name).one!
      def put(name, **) = by_name(name).changeset(:update, **).map(:touch).commit
      def set(name, **) = root.changeset(:create, **, name: name).map(:add_timestamps).commit
      def unset(name) = by_name(name).changeset(:delete).commit
      def exist?(name) = by_name(name).exist?
      def list = root.pluck(:name)

      # with associations
      private def with_all(relation) = relation
      private def with_associations(relation) = with_all(relation)
      def get_with_all(name) = with_all(by_name(name)).one
      def get_with_associations(name) = with_associations(by_name(name)).one

      private def paginate(relation, page: nil, per_page: nil)
        relation = relation.page(page || 1)
        relation = relation.per_page(per_page) if per_page
        relation
      end

      private def order(relation, order: nil)
        return relation if order.nil? || order.empty?

        relation.order do
          order.compact.map do |key, value|
            __send__(key).send(value)
          end
        end
      end

      private def search(relation, targets:, query: nil, case_sensitive: false)
        return relation if query.nil? || query.empty? || query == "%"

        relation.where do
          targets.map do |key|
            if case_sensitive
              __send__(key).like(query)
            else
              __send__(key).ilike(query)
            end
          end.reduce { |cond, next_cond| cond | next_cond }
        end
      end

      private def filter(relation, filter: nil)
        return relation if filter.nil? || filter.empty?

        filter.compact.each do |key, value|
          relation = relation.where(key => value)
        end
        relation
      end

      def index(page: nil, per_page: nil, order: nil, query: nil, filter: nil)
        relation = root
        relation = filter(relation, filter:)
        relation = search(relation, targets: [:name, :label], query:)
        relation = order(relation, order:)
        relation = paginate(relation, page:, per_page:)
        relation = with_associations(relation)
        [relation.to_a, relation.pager]
      end
    end
  end
end
