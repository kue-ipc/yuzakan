# frozen_string_literal: true

require_relative 'adapters/dummy_adapter'
require_relative 'adapters/local_adapter'
require_relative 'adapters/ldap_adapter'
require_relative 'adapters/active_directory_adapter'

module Yuzakan
  module Adapters
    module_function

    def hash
      @@adapters ||= list.map do |adapter|
        [adapter.name, datater]
      end

    end

    def list
      @@list ||= [
        Yuzakan::Adapters::DummyAdapter,
        Yuzakan::Adapters::LocalAdapter,
        Yuzakan::Adapters::LdapAdapter,
        Yuzakan::Adapters::ActiveDirectoryAdapter,
      ].freeze
    end

    def get(id)
      list[id]
    end

    def get_by_name(name)
      ::Yuzakan::Adapters.const_defined?(name) &&
        ::Yuzakan::Adapters.const_get(name)
    end

    def adapter_of_provider(provider)
      @@adapter_cache ||= {}

      if @@adapter_cache[provider.name].nil? ||
          @@adapter_cache[provider.name][:update_at] != provider.updated_at
        # Adapterの再作成

        # パラメーターがない場合は取得し直す。
        if provider.params.nil?
          provider = ProviderRepository.new.find_with_params(provider.id)
        end

        @@adapter_cache[provider.name] = {
          update_at: provider.update_at,
          adapter: provider.adapter.new(provider.params),
        }
      end
      @@adapter_cache[provider.name][:adapter]
    end
  end
end
