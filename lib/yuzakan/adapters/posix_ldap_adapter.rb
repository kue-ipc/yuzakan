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

      private def get_memberof_groups(user_entry)
        pg_filter = Net::LDAP::Filter.eq('gidNumber', user_entry.gidNumber.first)
        pg_opts = search_group_opts('*', filter: pg_filter)
        @logger.debug "ldap search: #{pg_opts}"
        primary_groups = ldap.search(pg_opts).to_a

        filter = Net::LDAP::Filter.eq('memberUid', user_entry.uid.first)
        opts = search_group_opts('*', filter: filter)
        @logger.debug "ldap search: #{opts}"
        primary_groups + ldap.search(opts).to_a
      end

      private def get_member_users(group_entry)
        filter = Net::LDAP::Filter.eq('memberOf', group_entry.dn)
        opts = search_user_opts('*', filter: filter)
        @logger.debug "ldap search: #{opts}"
        ldap.search(opts).to_a
      end

      private def add_member(group_entry, user_entry)
        return false if user_entry.memberof.include?(group_entry.dn)

        operations = [generate_operation_add(:member, user_entry.dn)]

        @logger.debug "ldap modify: #{group_entry.dn}"
        result = ldap.modify(dn: group_entry.dn, operations: operations)
        raise Error, ldap.get_operation_result.error_message unless result

        result
      end

      private def remove_member(group_entry, user_entry)
        return false if user_entry.memberof.exclude?(group_entry.dn)

        operations = [generate_operation_delete(:member, user_entry.dn)]

        @logger.debug "ldap modify: #{group_entry.dn}"
        result = ldap.modify(dn: group_entry.dn, operations: operations)
        raise Error, ldap.get_operation_result.error_message unless result

        result
      end
    end
  end
end
