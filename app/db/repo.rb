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

      private def paginate(relations, page: nil, per_page: nil)
        relations = relations.page(page || 1)
        relations = relations.per_page(per_page) if per_page
        relations
      end

      private def order(relations, order: nil)
        return relations if order.nil? || order.empty?

        relations.order do
          order.compact.map do |key, value|
            __send__(key).send(value)
          end
        end
      end

      private def search(relations, targets:, query: nil, case_sensitive: false)
        return relations if query.nil? || query.empty? || query == "%"

        relations.where do
          targets.map do |key|
            if case_sensitive
              __send__(key).like(query)
            else
              __send__(key).ilike(query)
            end
          end.reduce { |cond, next_cond| cond | next_cond }
        end
      end

      private def filter(relations, filter: nil)
        return relations if filter.nil? || filter.empty?

        filter.compact.each do |key, value|
          relations = relations.where(key => value)
        end
        relations
      end
    end
  end
end
