# auto_register: false
# frozen_string_literal: true

require "dry/operation"

module Yuzakan
  class ProviderOperation < Yuzakan::Operation
    def self.category(name)
      define_method(:category) do
        name
      end
    end

    include Deps[
      "repos.provider_repo",
    ]

    private def get_provider(provider)
      case provider
      in nil
        Failure([:nil, "provider"])
      in Yuzakan::Structs::Provider
        Success(provider)
      in String | Symbol
        if (struct = provider_repo.get(provider.to_s))
          Success(struct)
        else
          Failure([:not_found, "provider"])
        end
      end
    end

    private def get_providers(providers = nil, operation: nil)
      case providers
      in nil
        Success(provider_repo.all_capable_of_operation(operation))
      in []
        Success([])
      in [String | Symbol, *]
        Success(provider_repo.mget(*providers))
      in [Yuzakan::Structs::Provider, *]
        Success(providers)
      else
        Failure(:invalid_provider_list)
      end
    end

    private def cache_key(provider, name = nil, category: self.category)
      if name
        "provider:#{provider.name}:#{category}:#{name}"
      else
        "provider:#{provider.name}:list:#{category}"
      end
    end
  end
end
