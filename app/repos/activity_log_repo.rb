# frozen_string_literal: true

module Yuzakan
  module Repos
    class ActivityLogRepo < Yuzakan::DB::Repo
      commands :create, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}}
      commands update: :by_pk, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}}
      commands delete: :by_pk
      def all = activity_logs.to_a
      def find(id) = activity_logs.by_pk(id).one
      def first = activity_logs.first
      def last = activity_logs.last
      def clear = activity_logs.clear
    end
  end
end
