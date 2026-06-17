# frozen_string_literal: true

module Yuzakan
  module Repos
    class AffiliationRepo < Yuzakan::DB::Repo
      def put_changeset(name, **) = affiliations.by_name(name).changeset(:update, **).map(:touch).commit
      def put_command(name, **) = affiliations.by_name(name).command(:update, **UPDATE_TIMESTAMP).call(**)

      def put_changeset2(name, **) = affiliations.by_name(name).changeset(:update, **).commit
      def put_command2(name, **) = affiliations.by_name(name).command(:update).call(**)
    end
  end
end
