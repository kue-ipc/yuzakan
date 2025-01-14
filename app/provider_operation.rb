# auto_register: false
# frozen_string_literal: true

require "dry/operation"

module Yuzakan
  class ProviderOperation < Yuzakan::Operation
    include Deps[
      "repos.provider_repo",
    ]

    private def get_providers(providers = nil)
      providers =
        case providers
        in nil
          provider_repo.ordered_all_with_adapter_by_operation(:group_read)
        in []
          []
        in [String | Symbol, *]
          providers.map { |provider| provider_repo.get(provider) }.compact
        in [Yuzakann::Struct::Provider, *]
          providers
        else
          Failure(:invalid_provider_list)
        end
      Success(providers)
    end
  end
end
