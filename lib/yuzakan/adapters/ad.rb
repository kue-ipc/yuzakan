# frozen_string_literal: true

require "securerandom"

module Yuzakan
  module Adapters
    class AD < Ldap
      version "0.1.0"
      group true

      json do
        required(:host).filled(:str?, max_size?: 255)
        optional(:port).value(:int?, gt?: 0, lt?: 65535)
        optional(:protocol).value(included_in?: %w[ldap ldaps])
        optional(:certificate_check).value(:bool?)
        required(:bind_username).filled(:str?, max_size?: 255)
      end
      # self.params = [
      #   {
      #     name: :host,
      #     label: "ドメインコントローラーのホスト名/IPアドレス",
      #     description:
      #         "LDAPサーバーになっているドメインコントローラーのホスト名またはIPアドレスを指定します。" \
      #         "ドメインコントローラーでLDAPサーバー機能を有効にしておく必要があります。" \
      #         "ドメイン名(FQDN)を指定することもできますが、その場合は証明書のCNまたはDNSエントリにドメイン名が含まれている必要があります。",
      #     placeholder: "dc.example.jp",
      #   }, {
      #     name: :port,
      #     default: 636,
      #     fixed: true,
      #   }, {
      #     name: :protocol,
      #     default: "ldaps",
      #     fixed: true,
      #   }, {
      #     name: :certificate_check,
      #     description: "サーバー証明書のチェックを行います。ドメインコントローラーには正式証明書が必要になります。",
      #   }, {
      #     name: :bind_username,
      #     placeholder: "Administrator@example.jp",
      #   }, {
      #     name: :user_name_attr,
      #     default: "sAMAccountName",
      #     fixed: true,
      #   }, {
      #     name: :user_display_name_attr,
      #     default: "displayName",
      #     description: "AD標準はdisplayNameです。",
      #   }, {
      #     name: :user_email_attr,
      #     default: "mail",
      #     description: "AD標準はmailです。",
      #   }, {
      #     name: :user_search_filter,
      #     default: "(objectclass=user)",
      #     description: "ユーザー検索を行うときのフィルターです。" \
      #                  "LDAPの形式で指定します。" \
      #                  "何も指定しない場合は(objectclass=user)になります。",
      #   }, {
      #     name: :group_search_filter,
      #     description: "ユーザー検索を行うときのフィルターです。" \
      #                  "LDAPの形式で指定します。" \
      #                  "何も指定しない場合は(objectclass=group)になります。",
      #     default: "(objectclass=group)",
      #   }, {
      #     name: :create_user_object_classes,
      #     default: "user",
      #     fixed: true,
      #   }, {
      #     name: :group_name_attr,
      #     default: "sAMAccountName",
      #     fixed: true,
      #   }, {
      #     name: :password_scheme,
      #     delete: true,
      #   }, {
      #     name: :crypt_salt_format,
      #     delete: true,
      #   },
      #   *Ldap.params,
      # ].uniq { |param| param[:name] }.reject { |param| param[:delete] }
      #   .tap(&Yuzakan::Utils::Object.method(:deep_freeze))

      self.multi_attrs = Ldap.multi_attrs
      self.hide_attrs = Ldap.hide_attrs

      # override
      private def run_after_user_create(user, password: nil, **userdata)
        super

        # パスワードが未設定の場合、UAC適用に失敗するため、ランダムなパスワードを設定する。
        password ||= SecureRandom.alphanumeric(64)

        # 作成時にパスワードは設定されていないため、パスワード変更を行う
        ldap_user_change_password(user, password)

        # デフォルトUACの適用
        # 作成時には適用できないため、作成後にする必要がある。
        default_uac = AccountControl.new
        operations = [operation_replace(AccountControl::ATTRIBUTE_NAME,
          convert_ldap_value(default_uac.to_i))]
        ldap_modify(user.dn, operations)

        # 必ず変更がある
        true
      end

      private def user_entry_uac(user)
        AccountControl.new(user.first(AccountControl::ATTRIBUTE_NAME).to_i)
      end

      # userPrincipalName についてもチェックする
      # override
      private def user_entry_unmanageable?(user)
        super || @params[:bind_username].casecmp?(user.first("userPrincipalName").to_s)
      end

      # パスワード関連
      # ADではunicodePwdに平文パスワードを設定する。

      # ADでは作成時にパスワードを設定しても反映されない
      # override
      private def create_user_password_attributes(_password)
        {}
      end

      # 古いパスワードは取得できないため、常にreplaceで行うこと。
      # override
      private def change_password_operations(user, password, locked: false) # rubocop:disable Lint/UnusedMethodArgument
        [operation_replace("unicodePwd", generate_unicode_password(password))]
      end

      # ダブルコーテーションで囲ってUTF-16LEに変更する。
      private def generate_unicode_password(password)
        "\"#{password}\"".encode(Encoding::UTF_16LE).bytes.pack("c*")
      end

      # ロック関連
      # ACCOUNTDISABLE のフラグで管理する。
      # LOCKOUTは無視する。

      # override
      private def user_entry_locked?(user)
        user_entry_uac(user).accountdisable?
      end

      # override
      private def lock_operations(user)
        operations = []

        uac = user_entry_uac(user)
        unless uac.accountdisable?
          uac.accountdisable = true
          operations << operation_replace("userAccountControl",
            convert_ldap_value(uac.to_i))
        end

        operations
      end

      # override
      private def unlock_operations(user, password = nil)
        operations = []

        uac = user_entry_uac(user)
        if uac.accountdisable?
          uac.accountdisable = false
          operations << operation_replace("userAccountControl",
            convert_ldap_value(uac.to_i))
        end

        if password
          operations.concat(change_password_operations(user,
            password))
        end

        operations
      end
    end
  end
end
