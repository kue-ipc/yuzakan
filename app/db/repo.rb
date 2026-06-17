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

      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = root.to_a
      def find(id) = root.by_pk(id).one
      def first = root.first
      def last = root.last
      def clear = root.delete
    end
  end
end
