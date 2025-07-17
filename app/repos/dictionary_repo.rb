# frozen_string_literal: true

module Yuzakan
  module Repos
    class DictionaryRepo < Yuzakan::DB::Repo
      private def by_name(name) = dictionaries.by_name(normalize_name(name))

      def get(name) = by_name(name).one

      def set(name, **)
        by_name(name).changeset(:update, **).map(:touch).commit ||
          dictionaries.changeset(:create, **, name: normalize_name(name)).map(:add_timestamps).commit
      end

      def unset(name) = by_name(name).changeset(:delete).commit

      def exist?(name) = by_name(name).exist?

      def all = dictionaries.to_a

      def list = dictionaries.pluck(:name)

      def get_with_terms(name)
        by_name(name).combine(:terms).one
      end
    end
  end
end
