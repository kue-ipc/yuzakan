# frozen_string_literal: true

module Yuzakan
  module Repos
    class ActionLogRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = action_logs.to_a
      def find(id) = action_logs.by_pk(id).one
      def first = action_logs.first
      def last = action_logs.last
      def clear = action_logs.delete
    end
  end
end
