# Person LDAP
# inetOrgPerson and memberOf

require_relative 'ldap_password_adapter'

module Yuzakan
  module Adapters
    class PersonLdapAdapter < LdapBaseAdapter
      self.label = 'Person LDAP'

      self.params = LdapPasswordAdapter.params
    end
  end
end
