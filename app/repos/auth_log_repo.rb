# frozen_string_literal: true

module Yuzakan
  module Repos
    class AuthLogRepo < Yuzakan::DB::Repo
      commands :create, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}}
      commands update: :by_pk, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}}
      commands delete: :by_pk
      def all = auth_logs.to_a
      def find(id) = auth_logs.by_pk(id).one
      def first = auth_logs.first
      def last = auth_logs.last
      def clear = auth_logs.clear

      # TODO: 未整理

      def by_username(username)
        auth_logs.where(username: username)
      end

      def recent_by_username(username, ago)
        by_username(username)
          .where(result: ["success", "failure", "recover"])
          .where { created_at >= Time.now - ago }
          .order { created_at.desc }
      end
    end
  end
end
