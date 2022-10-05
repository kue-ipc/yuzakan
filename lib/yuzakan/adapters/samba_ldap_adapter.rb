require 'securerandom'
require 'smbhash'

# sambaLMPassword はデフォルト無効とし、設定済みは削除する。
# sambaNTPassword はデフォルト有効とし、設定する。

require_relative 'posix_ldap_adapter'

module Yuzakan
  module Adapters
    class SambaLdapAdapter < PosixLdapAdapter
      self.name = 'samba_ldap'
      self.label = 'Samba LDAP'
      self.version = '0.0.1'
      self.params = ha_merge(
        PosixLdapAdapter.params + [
          {
            name: :user_search_filter,
            default: '(&(objectclass=posixAccount)(objectClass=sambaSamAccount))',
          }, {
            name: :create_user_object_classes,
            description: 'オブジェクトクラスをカンマ区切りで入力してください。' \
                         'posixAccount と sambaSamAccount は自動的に追加されます。',
          }, {
            name: :samba_domain_sid,
            label: 'Samba ドメインSID',
            description: 'ユーザーのプリフィックスに使用するSambaドメインのSIDです。' \
                         '"S-1-5-21-(0..4294967295)-(0..4294967295)-(0..4294967295)"の形式で、' \
                         'ランダムな数を割り当ててください。',
            type: :string,
            placeholder: 'S-1-5-21-x-y-z',
            required: true,
          }, {
            name: :samba_nt_password,
            label: 'Samba NT パスワード設定',
            description: 'パスワード設定時にSamba NT パスワード(sambaNTPassword)を設定します。',
            type: :boolean,
            default: true,
          }, {
            name: :samba_lm_password,
            label: 'Samba Lanman パスワード設定',
            description:
              'パスワード設定時にSamba LM パスワード(sambaLMPassword)も設定します。' \
              'LM パスワードは14文字までしか有効ではないため、使用を推奨しません。',
            type: :boolean,
            default: false,
          }, {
            name: :auth_nt_password,
            label: 'Samba NT パスワード認証',
            description: 'NT パスワードでも認証を行います。',
            type: :boolean,
            default: false,
          },
        ], key: :name)
      self.multi_attrs = PosixLdapAdapter.multi_attrs
      self.hide_attrs = PosixLdapAdapter.hide_attrs + %w[sambaNTPassword sambaLMPassword].map(&:downcase)

      @@no_password = -'NO PASSWORDXXXXXXXXXXXXXXXXXXXXX' # rubocop:disable Style/ClassVars

      def user_auth(username, password)
        return true if super
        return false unless @params[:auth_nt_password]

        user = get_user_entry(username)
        return false unless user

        acct_flags = user['sambaAcctFlags']&.first
        return false if acct_flags && ['D', 'L'].any? { |c| acct_flags.include?(c) }

        user['sambaNTPassword'] == generate_nt_password(password)
      end

      private def change_password_operations(user, password, locked: false)
        operations = super
        operations << operation_delete('sambaNTPAssword') if user['sambaNTPAssword']&.first
        operations << operation_delete('sambaLMPAssword') if user['sambaLMPAssword']&.first
        operations << operation_add(
          'sambaNTPAssword',
          if @params[:samba_nt_password] then generate_nt_password(password) else @@no_password end)
        operations << operation_add(
          'sambaLMPassword',
          if @params[:samba_lm_password] then generate_lm_password(password) else @@no_password end)
        operations
      end

      private def generate_account_flags(no_password: false, disabled: false, home_required: false, auto_lock: false,
                                         password_dose_not_expire: false)
        flags = []
        flags << 'N' if no_password
        flags << 'D' if disabled
        flags << 'H' if home_required
        flags << 'U'
        flags << 'L' if auto_lock
        flags << 'X' if password_dose_not_expire
        flags_str = flags.join
        "[#{flags_str}#{' ' * (11 - flags_str.size)}]"
      end

      private def create_user_attributes(username, **userdata)
        attributes = super

        # object class
        attributes[attribute_name('objectClass')] << 'sambaSamAccount'

        # smaba SID
        uid_number =
          if attributes[attribute_name('uidNumber')].is_a?(Array)
            attributes[attribute_name('uidNumber')].first.to_i
          else
            attributes[attribute_name('uidNumber')].to_i
          end
        samba_sid = generate_samba_sid(uid_number)
        attributes[attribute_name('sambaSID')] = convert_ldap_value(samba_sid)

        attributes
      end

      private def generate_samba_sid(uid_number)
        user_id = (uid_number * 2) + 1000
        "#{@params[:samba_domain_sid]}-#{user_id}"
      end

      private def generate_nt_password(password)
        Smbhash.ntlm_hash(password)
      end

      # 14文字までしか対応できない
      private def generate_lm_password(password)
        Smbhash.lm_hash(password)
      end
    end
  end
end
