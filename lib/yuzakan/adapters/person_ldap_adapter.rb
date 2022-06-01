# Person LDAP
# inetOrgPerson and memberOf

require_relative 'ldap_adapter'

module Yuzakan
  module Adapters
    class PersonLdapAdapter < LdapAdapter
      self.name = 'person_ldap'
      self.label = 'Person LDAP'
      self.version = '0.0.1'
      self.params = LdapAdapter.params
      self.multi_attrs = LdapAdapter.multi_attrs
      self.hide_attrs = LdapAdapter.hide_attrs
    end
  end
end
