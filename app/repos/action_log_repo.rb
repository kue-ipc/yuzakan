# frozen_string_literal: true

module Yuzakan
  module Repos
    class ActionLogRepo < Yuzakan::DB::Repo
      # interface compatible with Hanami::Repository
      commands :create, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}}
      commands update: :by_pk, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}}
      commands delete: :by_pk
      def all = action_logs.to_a
      def find(id) = action_logs.by_pk(id).one
      def first = action_logs.first
      def last = action_logs.last
      def clear = action_logs.delete
    end
  end
end
