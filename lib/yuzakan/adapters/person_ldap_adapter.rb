# Person LDAP
# inetOrgPerson and memberOf

require_relative 'ldap_password_adapter'

module Yuzakan
  module Adapters
    class PersonLdapAdapter < LdapPasswordAdapter
      self.label = 'Person LDAP'
      self.params = LdapPasswordAdapter.params
      self.multi_attrs = LdapPasswordAdapter.multi_attrs
    end
  end
end
