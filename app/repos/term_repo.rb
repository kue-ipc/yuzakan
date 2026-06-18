# frozen_string_literal: true

module Yuzakan
  module Repos
    class TermRepo < Yuzakan::DB::Repo
      private def with_all(relation) = relation.combine(:dictionary)
      private def with_associations(relation) = relation
    end
  end
end
