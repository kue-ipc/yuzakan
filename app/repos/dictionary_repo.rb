# frozen_string_literal: true

module Yuzakan
  module Repos
    class DictionaryRepo < Yuzakan::DB::Repo
      private def with_all(relation) = relation.combine(:terms)

      # other interfaces
      # def get_with_terms(name)
      #   by_name(name).combine(:terms).one
      # end
    end
  end
end
