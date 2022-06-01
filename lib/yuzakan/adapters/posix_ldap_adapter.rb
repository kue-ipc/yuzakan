require_relative 'ldap_adapter'

module Yuzakan
  module Adapters
    class PosixLdapAdapter < LdapAdapter
      self.name = 'posix_ldap'
      self.label = 'Posix LDAP'
      self.version = '0.0.1'
      self.params = ha_merge(
        LdapAdapter.params + [
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
      self.multi_attrs = LdapAdapter.multi_attrs
      self.hide_attrs = LdapAdapter.hide_attrs

      private def get_memberof_groups(user_entry)
        (get_gidnumber_groups(user_entry) + get_memberuid_groups(user_entry)).compact.uniq
      end

      private def get_gidnumber_groups(user_entry)
        filter = Net::LDAP::Filter.eq('gidNumber', user_entry.gidNumber.first)
        opts = search_group_opts('*', filter: filter)
        ldap_search(opts).to_a
      end

      private def get_memberuid_groups(user_entry)
        filter = Net::LDAP::Filter.eq('memberUid', user_entry.uid.first)
        opts = search_group_opts('*', filter: filter)
        ldap_search(opts).to_a
      end

      private def get_member_users(group_entry)
        (get_gidnumber_users(gorup_entry) + get_memberuid_users(group_entry)).uniq
      end

      private def get_gidnumber_users(group_entry)
        filter = Net::LDAP::Filter.eq('gidNumber', group_entry.gidNumber.first)
        opts = search_user_opts('*', filter: filter)
        ldap_search(opts).to_a
      end

      private def get_memberuid_users(group_entry)
        group_entry.memberuid.map do |uid|
          filter = Net::LDAP::Filter.eq('uid', uid)
          opts = search_user_opts('*', filter: filter)
          ldap_search(opts).first
        end.compact
      end

      private def add_member(group_entry, user_entry)
        return false if group_entry.memberuid.include?(user_entry.uid.first)

        operations = [operation_add(:memberuid, user_entry.uid.first)]
        ldap_modify(group_entry.dn, operations)
      end

      private def remove_member(group_entry, user_entry)
        return false if group_entry.memberuid.exclude?(user_entry.uid.first)

        operations = [operation_delete(:memberuid, user_entry.uid.first)]
        ldap_modify(group_entry.dn, operations)
      end
    end
  end
end
