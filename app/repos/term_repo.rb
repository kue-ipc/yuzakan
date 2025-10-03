# frozen_string_literal: true

module Yuzakan
  module Repos
    class TermRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}}
      commands update: :by_pk, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}}
      commands delete: :by_pk
      def all = terms.to_a
      def find(id) = terms.by_pk(id).one
      def first = terms.first
      def last = terms.last
      def clear = terms.delete
    end
  end
end
