# frozen_string_literal: true

module Yuzakan
  module Repos
    class AffiliationRepo < Yuzakan::DB::Repo
      # compatible interface
      commands :create, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}}
      commands update: :by_pk, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}}
      commands delete: :by_pk
      def all = affiliations.to_a
      def find(id) = affiliations.by_pk(id).one
      def first = affiliations.first
      def last = affiliations.last
      def clear = affiliations.delete

      # common interface
      private def by_name(name) = affiliations.by_name(normalize_name(name))
      def get(name) = by_name(name).one

      def set(name, **)
        by_name(name).changeset(:update, **).map(:touch).commit ||
          affiliations.changeset(:create, **, name: normalize_name(name)).map(:add_timestamps).commit
      end

      def unset(name) = by_name(name).changeset(:delete).commit
      def exist?(name) = by_name(name).exist?
      def list = affiliations.pluck(:name)
    end
  end
end
