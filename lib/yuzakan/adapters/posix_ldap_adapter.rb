require_relative 'ldap_password_adapter'

module Yuzakan
  module Adapters
    class PosixLdapAdapter < LdapPasswordAdapter
      self.name = 'posix_ldap'
      self.label = 'Posix LDAP'
      self.version = '0.0.1'
      self.params = ha_merge(
        LdapPasswordAdapter.params + [
          {
            name: :user_name_attr,
            default: 'uid',
            placeholder: 'uid',
          }, {
            name: :user_search_filter,
            description: 'ユーザー検索を行うときのフィルターです。' \
                         'LDAPの形式で指定します。' \
                         '何も指定しない場合は(objectclass=posixAccount)になります。',
            default: '(objectclass=posixAccount)',
          }, {
            name: :group_search_filter,
            description: 'ユーザー検索を行うときのフィルターです。' \
                         'LDAPの形式で指定します。' \
                         '何も指定しない場合は(objectclass=posixGroup)になります。',
            default: '(objectclass=posixGroup)',
          },
        ], key: :name)
      self.multi_attrs = LdapPasswordAdapter.multi_attrs
      self.hide_attrs = LdapPasswordAdapter.hide_attrs

    end
  end
end
