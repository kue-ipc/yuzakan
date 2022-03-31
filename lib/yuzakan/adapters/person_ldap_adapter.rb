# Person LDAP
# inetOrgPerson and memberOf

require_relative 'ldap_password_adapter'

module Yuzakan
  module Adapters
    class PersonLdapAdapter < LdapPasswordAdapter
      self.name = 'person_ldap'
      self.label = 'Person LDAP'
      self.version = '0.0.1'
      self.params = LdapPasswordAdapter.params
      self.multi_attrs = LdapPasswordAdapter.multi_attrs
      self.hide_attrs = LdapPasswordAdapter.hide_attrs
    end
  end
end
