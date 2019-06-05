# frozen_string_literal: true

require_relative 'adapters/dummy_adapter'
require_relative 'adapters/local_adapter'
require_relative 'adapters/ldap_adapter'

module Yuzakan
  module Adapters
    module_function
    def list
      [
        Yuzakan::Adapters::DummyAdapter,
        Yuzakan::Adapters::LocalAdapter,
        Yuzakan::Adapters::LdapAdapter,
      ]
    end

    def get(id)
      list[id]
    end
  end
end
