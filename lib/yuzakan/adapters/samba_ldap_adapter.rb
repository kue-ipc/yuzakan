# frozen_string_literal: true

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
require_relative 'ad_adapter/account_control'

module Yuzakan
  module Adapters
    class SambaLdapAdapter < PosixLdapAdapter
      self.name = 'samba_ldap'
      self.display_name = 'Samba LDAP'
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

      group :primary

      SAMAB_NO_PASSWORD = 'NO PASSWORDXXXXXXXXXXXXXXXXXXXXX'

      # override
      def ldap_user_auth(user, password)
        return true if super
        return false unless @params[:auth_nt_password]

        user.first('sambaNTPassword') == generate_nt_password(password)
      end

      # override
      private def create_user_attributes(**userdata)
        attributes = super

        # object class
        attributes[attribute_name('objectClass')] << 'sambaSamAccount'

        # smaba SID
        unless attributes.key?(attribute_name('sambaSID'))
          uid_number = Array(attributes[attribute_name('uidNumber')]).first.to_i
          samba_sid = generate_samba_sid(uid_number)
          attributes[attribute_name('sambaSID')] = convert_ldap_value(samba_sid)
        end

        # samba SAC
        attributes[attribute_name(SambaAccountControl::ATTRIBUTE_NAME)] =
          convert_ldap_value(SambaAccountControl.new.to_s)

        attributes
      end

      ## パスワード関連

      # override
      private def create_user_password_attributes(password)
        attributes = super

        attributes[attribute_name('sambaNTPAssword')] = generate_nt_password(password) if @params[:samba_nt_password]
        attributes[attribute_name('sambaLMPAssword')] = generate_lm_password(password) if @params[:samba_lm_password]

        attributes
      end

      # override
      private def change_password_operations(user, password, locked: false)
        operations = super
        nt_password =
          if @params[:samba_nt_password]
            generate_nt_password(password)
          else
            SAMAB_NO_PASSWORD
          end
        operations << operation_add_or_replace('sambaNTPAssword', nt_password, user)
        lm_password =
          if @params[:samba_lm_password]
            generate_lm_password(password)
          else
            SAMAB_NO_PASSWORD
          end
        operations << operation_add_or_replace('sambaLMPAssword', lm_password, user)
        operations
      end

      # override
      private def user_entry_locked?(user)
        # ロックがかかっていないのであればかかっていない
        return false unless super

        user_entry_sac(user).intersect?(SambaAccountControl::LOCKED_FLAGS)
      end

      # override
      private def lock_operations(user)
        operations = super
        sac = user_entry_sac(user)
        sac.accountdisable = true
        operations << operation_add_or_replace(SambaAccountControl::ATTRIBUTE_NAME, sac.to_s, user)
        operations
      end

      # override
      private def unlock_operations(user, password = nil)
        operations = super
        sac = user_entry_sac(user)
        sac.accountdisable = false
        operations << operation_add_or_replace(SambaAccountControl::ATTRIBUTE_NAME, sac.to_s, user)
        operations
      end

      # Samba
      private def user_entry_sac(user)
        SambaAccountControl.new(
          user.first(SambaAccountControl::ATTRIBUTE_NAME) || SambaAccountControl::DEFAULT_USER_FLAGS)
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
