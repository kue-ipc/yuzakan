# frozen_string_literal: true

module Yuzakan
  module Repos
    class AffiliationRepo < Yuzakan::DB::Repo
      private def with_all(relation) = relation.combine(:users, :groups)
      private def with_associations(relation) = relation
    end
  end
end
