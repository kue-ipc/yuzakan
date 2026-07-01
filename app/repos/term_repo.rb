# frozen_string_literal: true

module Yuzakan
  module Repos
    class TermRepo < Yuzakan::DB::Repo
      private def with_all(relation) = relation.combine(:dictionary)
      private def with_associations(relation) = relation

      def get_of_dict(dict_name, term)
        terms.join(:dictionary).where(dictionaries: {name: dict_name}).by_term(term).one
      end
    end
  end
end
