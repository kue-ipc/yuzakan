# frozen_string_literal: true

module Yuzakan
  module Repos
    class DictionaryRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = dictionaries.to_a
      def find(id) = dictionaries.by_pk(id).one
      def first = dictionaries.first
      def last = dictionaries.last
      def clear = dictionaries.delete

      # common interfaces
      private def by_name(name) = dictionaries.by_name(name)
      def get(name) = by_name(name).one
      private def set_update(name, **) = by_name(name).command(:update, **UPDATE_TIMESTAMP).call(**)
      def set(name, **) = set_update(name, **) || create(name: name, **)
      def unset(name) = by_name(name).command(:delete).call
      def exist?(name) = by_name(name).exist?
      def list = dictionaries.pluck(:name)

      # other interfaces
      def get_with_terms(name)
        by_name(name).combine(:terms).one
      end
    end
  end
end
