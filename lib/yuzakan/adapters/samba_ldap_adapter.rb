# Samba LDAP
# sambaLMPassword はデフォルト無効とし、設定済みは削除する。
# sambaNTPassword はデフォルト有効とし、設定する。
# sambaAcctFlags の意味は下記の通り
#   D: アカウント無効
#   H: ホームディレクトリ必須
#   I: ドメイン信頼アカウント
#   L: 自動ロック中
#   M: MNSログオンユーザーアカウント
#   N: パスワード不要(パスワード無しでログオン可能)
#   S: サーバー信頼アカウント
#   T: 一時的な重複アカウント
#   U: 一般ユーザーアカウント
#   W: ワークステーション信頼アカウント
#   X: パスワード無期限

require 'securerandom'
require 'smbhash'

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

      # rubocop:disable Style/ClassVars
      @@no_password = -'NO PASSWORDXXXXXXXXXXXXXXXXXXXXX'
      @@account_control_description = {
        N: 'No password required',
        D: 'Account disabled',
        H: 'Home directory required',
        T: 'Temporary duplicate of other account',
        U: 'Regular user account',
        M: 'MNS logon user account',
        W: 'Workstation Trust Account',
        S: 'Server Trust Account',
        L: 'Automatic Locking',
        X: 'Password does not expire',
        I: 'Domain Trust Account',
      }
      @@account_control_flags = @@account_control_description.keys
      @@default_user_acct_flags = [:U, :X]
      # rubocop:enable Style/ClassVars

      # override
      def user_auth(username, password)
        return true if super
        return false unless @params[:auth_nt_password]

        user = get_user_entry(username)
        return false if user.nil?
        return false if user_entry_locked?(user)

        user.first('sambaNTPassword') == generate_nt_password(password)
      end

      # override
      private def create_user_attributes(username, **userdata)
        attributes = super

        # object class
        attributes[attribute_name('objectClass')] << 'sambaSamAccount'

        # smaba SID
        unless attributes.key?(attribute_name('sambaSID'))
          uid_number = Array(attributes[attribute_name('uidNumber')]).first.to_i
          samba_sid = generate_samba_sid(uid_number)
          attributes[attribute_name('sambaSID')] = convert_ldap_value(samba_sid)
        end

        attributes[attribute_name('sambaAcctFlags')] = generate_samba_acct_flags(@@default_user_acct_flags)

        attributes
      end

      # override
      private def change_password_operations(user, password, locked: false)
        operations = super
        operations << operation_delete('sambaNTPAssword') if user.first('sambaNTPAssword')
        operations << operation_delete('sambaLMPAssword') if user.first('sambaLMPAssword')
        operations << operation_add(
          'sambaNTPAssword',
          if @params[:samba_nt_password] then generate_nt_password(password) else @@no_password end)
        operations << operation_add(
          'sambaLMPassword',
          if @params[:samba_lm_password] then generate_lm_password(password) else @@no_password end)
        operations
      end

      # override
      private def user_entry_locked?(user)
        # ロックがかかっていないのであればかかっていない
        return false unless super

        acct_flags = read_samba_acct_flags(user.first('sambaAcctFlags'))
        return false unless acct_flags

        [:D, :L].any? { |f| acct_flags.include?(f) }
      end

      # override
      private def lock_operations(user)
        operations = super
        operations << operation_samba_acct_flags(user, add: [:D])
        operations
      end

      # override
      private def unlock_operations(user, password = nil)
        operations = super
        operations << operation_samba_acct_flags(user, delete: [:D, :L])
        operations
      end

      # Samba
      private def generate_samba_acct_flags(flags)
        flags = flags.map { |f| f.chr.upcase.intern } & @@account_control_flags
        "[#{flags.to_a.join}#{' ' * (11 - flags.size)}]"
      end

      private def read_samba_acct_flags(str)
        return unless str

        m = /^\[([\w\s]*)\]$/.match(str)
        unless m
          @logger.warn("invalid sambaAcctFlags: #{str}")
          return
        end

        m[1].each_char.map { |c| c.upcase.intern } & @@account_control_flags
      end

      private def operation_samba_acct_flags(user, add: [], delete: [])
        acct_flags = user.first('sambaAcctFlags')
        if acct_flags
          operation_replace('sambaAcctFlags',
                            generate_samba_acct_flags((acct_flags | add) - delete))
        else
          operation_add('sambaAcctFlags',
                        generate_samba_acct_flags((@@default_user_acct_flags | add) - delete))
        end
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
