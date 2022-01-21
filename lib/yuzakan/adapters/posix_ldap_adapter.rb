require_relative 'base_ldap_adapter'

module Yuzakan
  module Adapters
    class PosixLdapAdapter < BaseLdapAdapter
      self.label = 'Posix LDAP'

      self.params = BaseLdapAdapter.params
    end
  end
end
