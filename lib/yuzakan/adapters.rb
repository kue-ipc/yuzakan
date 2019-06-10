# frozen_string_literal: true

require_relative 'adapters/dummy_adapter'
require_relative 'adapters/local_adapter'
require_relative 'adapters/ldap_adapter'

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
      ].freeze
    end

    def get(id)
      list[id]
    end

    def get_by_name(name)
      ::Yuzakan::Adapters.const_defined?(name) &&
        ::Yuzakan::Adapters.const_get(name)
    end
  end
end
