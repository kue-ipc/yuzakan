require_relative 'ldap_base_adapter'

module Yuzakan
  module Adapters
    class AdAdapter < LdapBaseAdapter
      self.name = 'ad'
      self.label = 'Active Directory'
      self.version = '0.0.1'
      self.params = ha_merge(
        LdapBaseAdapter.params + [
          {
            name: :host,
            label: 'ドメインコントローラーのホスト名/IPアドレス',
            description:
                'LDAPサーバーになっているドメインコントローラーのホスト名またはIPアドレスを指定します。' \
                'ドメインコントローラーでLDAPサーバー機能を有効にしておく必要があります。' \
                'ドメイン名(FQDN)を指定することもできますが、その場合は証明書のCNまたはDNSエントリにドメイン名が含まれている必要があります。',
            placeholder: 'dc.example.jp',
          }, {
            name: :port,
            default: 636,
            fixed: true,
          }, {
            name: :protocol,
            default: 'ldaps',
            fixed: true,
          }, {
            name: :certificate_check,
            description: 'サーバー証明書のチェックを行います。ドメインコントローラーには正式証明書が必要になります。',
          }, {
            name: :bind_username,
            placeholder: 'Administrator@example.jp',
          }, {
            name: :user_name_attr,
            default: 'sAMAccountName',
            fixed: true,
          }, {
            name: :user_search_filter,
            default: '(objectclass=user)',
            description: 'ユーザー検索を行うときのフィルターです。' \
                         'LDAPの形式で指定します。' \
                         '何も指定しない場合は(objectclass=user)になります。',
          }, {
            name: :group_search_filter,
            description: 'ユーザー検索を行うときのフィルターです。' \
                         'LDAPの形式で指定します。' \
                         '何も指定しない場合は(objectclass=group)になります。',
            default: '(objectclass=group)',
          },
        ], key: :name)
      self.multi_attrs = LdapBaseAdapter.multi_attrs + %w[member memberOf].map(&:downcase)
      self.hide_attrs = LdapBaseAdapter.hide_attrs

      def member_list(groupname)
        group = read_group(groupname)
        return if gorup.nil?

        filter = Net::LDAP::Filter.eq('memberOf', group[:attrs]['dn'])
        filter &= Net::LDAP::Filter.construct(@params[:user_search_filter]) if @params[:user_search_filter]

        user_opts = search_user_opts('*', filter: filter)
        @logger.debug "ldap search: #{user_opts}"
        generate_ldap.search(user_opts)
          .map { |user| user[@params[:user_name_attr]].first.downcase }
      end

      def member_add(groupname, username)
        group = read_group(groupname)
        return if gorup.nil?

        user = read_user(user)
        return if user.nil?

        group_dn = group[:attrs]['dn']
        user_dn = user[:attrs]['dn']

        return true if user[:attrs]['memberof'].include?(group_dn)

        operations = [generate_operation_add(:memberOf, gorup_dn)]

        @logger.debug "ldap modify: #{user_dn}"
        modify_result = ldap.modify(dn: user_dn, operations: operations)
        raise ldap.get_operation_result.error_message unless modify_result

        true
      end

      def member_delete(groupname, username)
        group = read_group(groupname)
        return if gorup.nil?

        user = read_user(user)
        return if user.nil?

        group_dn = group[:attrs]['dn']
        user_dn = user[:attrs]['dn']

        return true if user[:attrs]['memberof'].exclude?(group_dn)

        operations = [generate_operation_delete(:memberOf, gorup_dn)]

        @logger.debug "ldap modify: #{user_dn}"
        modify_result = ldap.modify(dn: user_dn, operations: operations)
        raise ldap.get_operation_result.error_message unless modify_result

        true
      end

      # ADではunicodePwdに平文パスワードを設定することで変更できる。
      private def change_password_operations(password)
        [generate_operation_replace(:unicodePwd, generate_unicode_password(password))]
      end

      # ダブルコーテーションで囲ってUTF-16LEに変更する。
      private def generate_unicode_password(password)
        "\"#{password}\"".encode(Encoding::UTF_16LE).bytes.pack('c*')
      end
    end
  end
end
