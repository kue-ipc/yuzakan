# frozen_string_literal: true

# Samba LDAP
# sambaLMPassword はデフォルト無効とし、設定済みは削除する。
# sambaNTPassword はデフォルト有効とし、設定する。

require "securerandom"
require "smbhash"

module Yuzakan
  module Adapters
    class SambaLdap < PosixLdap
      self.name = "samba_ldap"
      self.display_name = "Samba LDAP"
      self.version = "0.0.1"
      self.params = [
        {
          name: :user_search_filter,
          default: "(&(objectclass=posixAccount)(objectClass=sambaSamAccount))",
        }, {
          name: :create_user_object_classes,
          description: "オブジェクトクラスをカンマ区切りで入力してください。" \
                       "posixAccount と sambaSamAccount は自動的に追加されます。",
        }, {
          name: :samba_domain_sid,
          label: "Samba ドメインSID",
          description: "ユーザーのプリフィックスに使用するSambaドメインのSIDです。" \
                       '"S-1-5-21-(0..4294967295)-(0..4294967295)-(0..4294967295)"の形式で、' \
                       "ランダムな数を割り当ててください。",
          type: :string,
          placeholder: "S-1-5-21-x-y-z",
          required: true,
        }, {
          name: :samba_nt_password,
          label: "Samba NT パスワード設定",
          description: "パスワード設定時にSamba NT パスワード(sambaNTPassword)を設定します。",
          type: :boolean,
          default: true,
        }, {
          name: :samba_lm_password,
          label: "Samba Lanman パスワード設定",
          description:
              "パスワード設定時にSamba LM パスワード(sambaLMPassword)も設定します。" \
              "LM パスワードは14文字までしか有効ではないため、使用を推奨しません。",
          type: :boolean,
          default: false,
        }, {
          name: :auth_nt_password,
          label: "Samba NT パスワード認証",
          description: "NT パスワードでも認証を行います。",
          type: :boolean,
          default: false,
        },
        *PosixLdap.params,
      ].uniq { |param| param[:name] }.reject { |param| param[:delete] }
        .tap(&Yuzakan::Utils::Object.method(:deep_freeze))

      self.multi_attrs = PosixLdap.multi_attrs
      self.hide_attrs = PosixLdap.hide_attrs + %w[sambaNTPassword
        sambaLMPassword].map(&:downcase)

      group :primary

      SAMAB_NO_PASSWORD = "NO PASSWORDXXXXXXXXXXXXXXXXXXXXX"

      # override
      def ldap_user_auth(user, password)
        return true if super
        return false unless @params[:auth_nt_password]

        user.first("sambaNTPassword") == generate_nt_password(password)
      end

      # override
      private def create_user_attributes(**userdata)
        attributes = super

        # object class
        attributes[attribute_name("objectClass")] << "sambaSamAccount"

        # samba SID
        unless attributes.key?(attribute_name("sambaSID"))
          uid_number = Array(attributes[attribute_name("uidNumber")]).first.to_i
          samba_sid = generate_samba_sid(uid_number)
          attributes[attribute_name("sambaSID")] = convert_ldap_value(samba_sid)
        end

        # samba SAC
        attributes[attribute_name(AccountControl::ATTRIBUTE_NAME)] =
          convert_ldap_value(AccountControl.new.to_s)

        attributes
      end

      ## パスワード関連

      # override
      private def create_user_password_attributes(password)
        attributes = super

        if @params[:samba_nt_password]
          attributes[attribute_name("sambaNTPAssword")] =
            generate_nt_password(password)
        end
        if @params[:samba_lm_password]
          attributes[attribute_name("sambaLMPAssword")] =
            generate_lm_password(password)
        end

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
        operations << operation_add_or_replace("sambaNTPAssword", nt_password,
          user)
        lm_password =
          if @params[:samba_lm_password]
            generate_lm_password(password)
          else
            SAMAB_NO_PASSWORD
          end
        operations << operation_add_or_replace("sambaLMPAssword", lm_password,
          user)
        operations
      end

      # override
      private def user_entry_locked?(user)
        # ロックがかかっていないのであればかかっていない
        return false unless super

        user_entry_sac(user).accountdisable?
      end

      # override
      private def lock_operations(user)
        operations = super

        sac = user_entry_sac(user)
        unless sac.accountdisable?
          sac.accountdisable = true
          operations << operation_add_or_replace(
            AccountControl::ATTRIBUTE_NAME, sac.to_s, user)
        end

        operations
      end

      # override
      private def unlock_operations(user, password = nil)
        operations = super

        sac = user_entry_sac(user)
        if sac.accountdisable?
          sac.accountdisable = false
          operations << operation_add_or_replace(
            AccountControl::ATTRIBUTE_NAME, sac.to_s, user)
        end

        operations
      end

      # Samba
      private def user_entry_sac(user)
        AccountControl.new(
          user.first(AccountControl::ATTRIBUTE_NAME) || AccountControl::DEFAULT_USER_FLAGS)
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
