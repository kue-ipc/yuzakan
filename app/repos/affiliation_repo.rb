# frozen_string_literal: true

module Yuzakan
  module Repos
    class AffiliationRepo < Yuzakan::DB::Repo
      private def with_all(relation) = relation.combine(:users, :groups)
      private def with_associations(relation) = relation

      def get_of_group(name)
        affiliations.join(:groups).where(groups: {name:}).one
      end

      def get_of_user(name)
        affiliations.join(:users).where(users: {name:}).one
      end
    end
  end
end
