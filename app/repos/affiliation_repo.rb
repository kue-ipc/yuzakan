# frozen_string_literal: true

module Yuzakan
  module Repos
    class AffiliationRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = affiliations.to_a
      def find(id) = affiliations.by_pk(id).one
      def first = affiliations.first
      def last = affiliations.last
      def clear = affiliations.delete

      # common interfaces
      private def by_name(name) = affiliations.by_name(name)
      def get(name) = by_name(name).one
      def set(name, **) = by_name(name).command(:update, **UPDATE_TIMESTAMP).call(**) || create(name: name, **)
      def unset(name) = by_name(name).command(:delete).call
      def exist?(name) = by_name(name).exist?
      def list = affiliations.pluck(:name)

      # index = filter & search & order & paginate
      def index(page: nil, per_page: nil, order: nil, query: nil, filter: nil)
        relation = affiliations

        relation = filter(relation, filter:)
        relation = search(relation, targets: [:name, :label], query:)
        relation = order(relation, order:)
        relation = paginate(relation, page:, per_page:)
        [relation.to_a, relation.pager]
      end
    end
  end
end
