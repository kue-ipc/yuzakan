# frozen_string_literal: true

module Yuzakan
  module Providers
    class CreateGroup < Yuzakan::Operation
      include Deps[
        "repos.provider_repo",
        "providers.get_adapter",
        "providers.convert_data",
        "cache_store",
      ]

      def call
      end
    end
  end
end
