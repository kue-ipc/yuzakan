# frozen_string_literal: true

module Yuzakan
  module Repos
    class DictionaryRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}}
      commands update: :by_pk, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}}
      commands delete: :by_pk
      def all = dictionaries.to_a
      def find(id) = dictionaries.by_pk(id).one
      def first = dictionaries.first
      def last = dictionaries.last
      def clear = dictionaries.delete

      # common interfaces
      private def by_name(name) = dictionaries.by_name(normalize_name(name))
      def get(name) = by_name(name).one

      def set(name, **)
        by_name(name).changeset(:update, **).map(:touch).commit ||
          dictionaries.changeset(:create, **, name: normalize_name(name)).map(:add_timestamps).commit
      end

      def unset(name) = by_name(name).changeset(:delete).commit
      def exist?(name) = by_name(name).exist?
      def list = dictionaries.pluck(:name)

      # other interfaces
      def get_with_terms(name)
        by_name(name).combine(:terms).one
      end
    end
  end
end
