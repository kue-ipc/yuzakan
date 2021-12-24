require 'securerandom'
require 'net/ldap'
require 'smbhash'

# パスワード変更について
# userPassword は {CRYPT}$1$%.8s をデフォルトする。
# sambaLMPassword はデフォルト無効とし、設定済みは削除する。
# sambaNTPassword はデフォルト有効とし、設定する。

require_relative 'ldap_adapter'

module Yuzakan
  module Adapters
    class SambaLdapAdapter < LdapAdapter
      LABEL = 'Samba LDAP'

      PARAMS = PARAM_TYPES = (LdapAdapter::PARAM_TYPES + [
        {
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
        },
        {
          name: 'samba_lm_password',
          label: 'Samba Lanman パスワード設定',
          description:
      'パスワード設定時にSamba LM パスワード(sambaLMPassword)も設定します。LM パスワードは14文字までしか有効ではないため、使用を推奨しません。',
          type: :boolean,
          default: false,
        },
      ]).reject do |data|
        %i[user_name_attr password_scheme crypt_salt_format].include?(data[:name])
      end

      def self.selectable?
        true
      end

      def auth(username, password)
        opts = search_user_opts(username).merge(password: password)
        # bind_as is re bind, so DON'T USE `ldap`
        user = generate_ldap.bind_as(opts)
        normalize_user(user&.first) if user
      end

      private def change_password_operations(password, existing_attrs = [])
        operations = []

        operations << generate_operation_replace(:sambantpassword, generate_nt_password(password))
        operations << generate_operation_delete(:sambalmpassword) if existing_attrs.include?(:sambalmpassword)

        operations
      end

      private def normalize_user(user)
        return if user.nil?

        data = {
          name: user[:uid]&.first,
          display_name: user[:'displayname;lang-ja']&.first ||
                        user[:displayname]&.first ||
                        user[@params[:user_name_attr]]&.first,
          email: user[:email]&.first || user[:mail]&.first,
        }

        user.each do |name, values|
          case name
          when :userpassword, :sambantpassword, :sambalmpassword
            next
          when :objectclass
            data[name.to_s] = values
          else
            data[name.to_s] = values.first
          end
        end

        data
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
