require_relative 'ldap_password_adapter'

module Yuzakan
  module Adapters
    class PosixLdapAdapter < LdapPasswordAdapter
      self.label = 'Posix LDAP'
      self.params = LdapPasswordAdapter.params
      self.multi_attrs = LdapPasswordAdapter.multi_attrs
    end
  end
end
