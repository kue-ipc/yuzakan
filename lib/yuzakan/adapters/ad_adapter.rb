require_relative 'ldap_adapter'
require_relative 'ad_adapter/account_control'

module Yuzakan
  module Adapters
    class AdAdapter < LdapAdapter
      self.name = 'ad'
      self.label = 'Active Directory'
      self.version = '0.0.1'
      self.params = ha_merge(
        LdapAdapter.params + [
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
            name: :user_display_name_attr,
            default: 'displayName',
            description: 'AD標準はdisplayNameです。',
          }, {
            name: :user_email_attr,
            default: 'mail',
            description: 'AD標準はmailです。',
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
          }, {
            name: :create_user_object_classes,
            default: 'user',
            fixed: true,
          }, {
            name: :password_scheme,
            delete: true,
          }, {
            name: :crypt_salt_format,
            delete: true,
          },
        ], key: :name)
      self.multi_attrs = LdapAdapter.multi_attrs
      self.hide_attrs = LdapAdapter.hide_attrs

      private def run_after_user_create(username, password = nil, **userdata)
        super
        user = get_user_entry(username)
        uac = user_entry_uac(user)
        uac.add(AccountControl::DEFAULT_USER_FLAGS)
        operations = [operation_replace('userAccountControl', convert_ldap_value(uac.flags))]
        ldap_modify(user.dn, operations)
      end

      private def user_entry_uac(user)
        AccountControl.new(user.first('userAccountControl').to_i)
      end

      # ACCOUNTDISABLED と LOCKOUT 両方をチェックする
      # override
      private def user_entry_locked?(user)
        user_entry_uac(user).intersect?(AccountControl::LOCKED_FLAGS)
      end

      # userPrincipalName についてもチェックする
      # override
      private def user_entry_unmanageable?(user)
        super || @params[:bind_username].casecmp?(user.first('userPrincipalName').to_s)
      end

      # ADではunicodePwdに平文パスワードを設定することで変更できる。
      # 古いパスワードはわからないため、常にreplaceで行うこと。
      # override
      private def change_password_operations(user, password, locked: false) # rubocop:disable Lint/UnusedMethodArgument
        [operation_replace('unicodePwd', generate_unicode_password(password))]
      end

      # ダブルコーテーションで囲ってUTF-16LEに変更する。
      private def generate_unicode_password(password)
        "\"#{password}\"".encode(Encoding::UTF_16LE).bytes.pack('c*')
      end

      # ACCOUNTDISABLE のフラグを立てる
      # LOCKOUTはそのまま
      # override
      private def lock_operations(user)
        uac = user_entry_uac(user)
        uac.add(AccountControl::Flag::ACCOUNTDISABLE)
        [operation_replace('userAccountControl', convert_ldap_value(uac.flags))]
      end

      # ACCOUNTDISABLE のフラグを解除する
      # LOCKOUTはそのまま
      # override
      private def unlock_operations(user, password = nil)
        uac = user_entry_uac(user)
        uac.delete(AccountControl::Flag::ACCOUNTDISABLE)
        operations = [operation_replace('userAccountControl', convert_ldap_value(uac.flags))]
        operations.concat(change_password_operations(user, password)) if password
        operations
      end
    end
  end
end
