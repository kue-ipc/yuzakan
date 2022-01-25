require_relative 'ldap_base_adapter'

module Yuzakan
  module Adapters
    class AdAdapter < LdapBaseAdapter
      self.label = 'Active Directory'
      self.params = ha_merge(*LdapBaseAdapter.params, {
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
        name: :user_dn_attr,
        default: 'cn',
        fixed: true,
      }, {
        name: :user_name_attr,
        default: 'sAMAccountName',
        fixed: true,
      }, {
        name: :user_search_filter,
        default: '(objectclass=user)',
        description:
          'ユーザー検索を行うときのフィルターです。' \
          'LDAPの形式で指定します。' \
          '何も指定しない場合は(objectclass=user)になります。',
      }, key: :name)
      self.multi_attrs = LdapBaseAdapter.multi_attrs
      self.hide_attrs = LdapBaseAdapter.hide_attrs

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
