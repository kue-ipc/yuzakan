# frozen_string_literal: true

require "hanami/db/repo"

module Yuzakan
  module DB
    class Repo < Hanami::DB::Repo
      CREATE_TIMESTAMP = {
        use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}},
      }.freeze
      UPDATE_TIMESTAMP = {
        use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}},
      }.freeze

      # # compatible interfaces
      # commands :create, **CREATE_TIMESTAMP
      # commands update: :by_pk, **UPDATE_TIMESTAMP
      # commands delete: :by_pk
      # def all = relation.to_a
      # def find(id) = relation.by_pk(id).one
      # def first = relation.first
      # def last = relation.last
      # def clear = relation.delete

      # # common interface
      # private def by_name(name) = relation.by_name(name)
      # def get(name) = by_name(name).one
      # private def set_update(name, **) = by_name(name).command(:update, **UPDATE_TIMESTAMP).call(**)
      # private def set_create(name, **) = create(name: name, **)
      # # private def set_update(name, **) = by_name(name).changeset(:update, **).map(:touch).commit
      # # private def set_create(name, **) = relation.changeset(:create, **, name: name).map(:add_timestamps).commit
      # def set(name, **) = set_update(name, **) || set_create(name, **)
      # def unset(name) = by_name(name).changeset(:delete).commit
      # def exist?(name) = by_name(name).exist?
      # def list = relation.pluck(:name)

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
    end
  end
end
