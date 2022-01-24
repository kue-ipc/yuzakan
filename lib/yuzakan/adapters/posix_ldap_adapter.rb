require_relative 'ldap_password_adapter'

module Yuzakan
  module Adapters
    class PosixLdapAdapter < LdapBaseAdapter
      self.label = 'Posix LDAP'

      self.params = LdapPasswordAdapter.params
    end
  end
end
