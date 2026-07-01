# frozen_string_literal: true

module Yuzakan
  module Operations
    class LookupDict < Yuzakan::Operation
      include Deps["repos.term_repo"]

      def call(dict, term)
        term_repo.get_of_dict(dict, term)&.description
      end
    end
  end
end
