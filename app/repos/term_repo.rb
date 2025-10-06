# frozen_string_literal: true

module Yuzakan
  module Repos
    class TermRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = terms.to_a
      def find(id) = terms.by_pk(id).one
      def first = terms.first
      def last = terms.last
      def clear = terms.delete
    end
  end
end
