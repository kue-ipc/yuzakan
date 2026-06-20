# frozen_string_literal: true

require "hanami/db/repo"

module Yuzakan
  module DB
    class Repo < Hanami::DB::Repo
      class NameError < StandardError; end
      class NotFoundNameError < NameError; end
      class DuplicateNameError < NameError; end

      CREATE_TIMESTAMP = {
        use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}},
      }.freeze
      UPDATE_TIMESTAMP = {
        use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}},
      }.freeze

      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = root.to_a
      def find(id) = root.by_pk(id).one
      def first = root.first
      def last = root.last
      def clear = root.delete

      # common interface
      private def by_name(name) = root.by_name(name)
      def get(name) = by_name(name).one
      def get!(name) = get(name) || raise(NotFoundError, "Not found: #{name}")
      def put(name, **) = by_name(name).changeset(:update, **, name: name).map(:touch).commit
      def put!(name, **) = put(name, **) || raise(NotFoundError, "Not found: #{name}")
      private def _set(name, **) = root.changeset(:create, **, name: name).map(:add_timestamps).commit
      def set(name, **) = put(name, **) || _set(name, **)

      def set!(name, **)
        raise(DuplicateNameError, "Already exists: #{name}") if exist?(name)

        _set(name, **)
      end

      def unset(name) = by_name(name).changeset(:delete).commit
      def unset!(name) = unset(name) || raise(NotFoundError, "Not found: #{name}")

      def rename!(old_name, new_name)
        if old_name == new_name
          get!(old_name)
        elsif exist?(new_name)
          raise(DuplicateNameError, "Already exists: #{new_name}")
        else
          by_name(old_name).changeset(:update, name: new_name).map(:touch).commit ||
            raise(NotFoundError, "Not found: #{name}")
        end
      end

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
