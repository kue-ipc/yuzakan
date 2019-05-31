# frozen_string_literal: true

require_relative './adapters/dummy_adapter'
require_relative './adapters/local_adapter'
require_relative './adapters/ldap_adapter'

module Yuzakan
  module Adapters
    LIST = [
      Yuzakan::Adapters::DummyAdapter,
      Yuzakan::Adapters::LocalAdapter,
      Yuzakan::Adapters::LdapAdapter,
    ].freeze
  end
end
