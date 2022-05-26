require 'securerandom'
require 'smbhash'

# sambaLMPassword はデフォルト無効とし、設定済みは削除する。
# sambaNTPassword はデフォルト有効とし、設定する。

require_relative 'ldap_base_adapter'

module Yuzakan
  module Adapters
    class SambaLdapAdapter < LdapBaseAdapter
      self.name = 'samba_ldap'
      self.label = 'Samba LDAP'
      self.version = '0.0.1'
      self.params = ha_merge(
        LdapBaseAdapter.params + [
          {
            name: :user_name_attr,
            default: 'uid',
            fixed: true,
          }, {
            name: :user_esarch_filter,
            default: '(objectClass=sambaSamAccount)',
          }, {
            name: :samba_domain_sid,
            label: 'Samba ドメインSID',
            description: 'ユーザーのプリフィックスに使用するSambaドメインのSID',
            type: :string,
            default: 'S-1-5-21-0-0-0',
          }, {
            name: :samba_nt_password,
            label: 'Samba NT パスワード設定',
            description:
      'パスワード設定時にSamba NT パスワード(sambaNTPassword)を設定します。',
            type: :boolean,
            default: true,
          }, {
            name: :samba_lm_password,
            label: 'Samba Lanman パスワード設定',
            description:
      'パスワード設定時にSamba LM パスワード(sambaLMPassword)も設定します。LM パスワードは14文字までしか有効ではないため、使用を推奨しません。',
            type: :boolean,
            default: false,
          },
        ], key: :name)
      self.multi_attrs = LdapBaseAdapter.multi_attrs
      self.hide_attrs = LdapBaseAdapter.hide_attrs + %w[sambaNTPassword sambaLMPassword].map(&:downcase)

      @@no_password = -'NO PASSWORDXXXXXXXXXXXXXXXXXXXXX' # rubocop:disable Style/ClassVars

      def create(username, _password = nil, **attrs)
        user_attrs = read(username)

        user_attrs[:classobject].include?('sambaSamAccount')
        user_attrs.merge(attrs)
      end

      def auth(username, password)
        user = read(username)
        user &&
          ['D', 'L'].none? { |c| user.dig(:attrs, :sambaacctflags)&.include?(c) } &&
          user['sambantpassword'] == generate_nt_password(password)
      end

      private def change_password_operations(password)
        nt_password =
          if @params[:samba_nt_password]
            generate_nt_password(password)
          else
            @@no_password
          end

        lm_password =
          if @params[:samba_lm_password]
            generate_lm_password(password)
          else
            @@no_password
          end

        [
          generate_operation_replace(:sambantpassword, nt_password),
          generate_operation_replace(:sambalmpassword, lm_password),
        ]
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

      private def generate_user_sid(user)
        user_id = (user[:uidnumber].first * 2) + 1000
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
