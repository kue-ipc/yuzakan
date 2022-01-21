# Person LDAP
# inetOrgPerson and memberOf

require_relative 'base_ldap_adapter'

module Yuzakan
  module Adapters
    class PersonLdapAdapter < BaseLdapAdapter
      self.label = 'Person LDAP'

      self.params = BaseLdapAdapter.params
    end
  end
end
