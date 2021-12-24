require 'securerandom'
require 'net/ldap'

require 'base64'
require 'digest'

# パスワード変更について
# userPassword は {CRYPT}$1$%.8s をデフォルトする。
# sambaLMPassword はデフォルト無効とし、設定済みは削除する。
# sambaNTPassword はデフォルト有効とし、設定する。

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class LdapAdapter < AbstractAdapter
      LABEL = 'LDAP'

      PARAMS = PARAM_TYPES = [
        {
          name: :host,
          label: 'サーバーのホスト名/IPアドレス',
          description: 'LDAPサーバーのホスト名またはIPアドレスを指定します。',
          type: :string,
          placeholder: 'ldap.example.jp',
        }, {
          name: :port,
          label: 'ポート',
          description:
      'LDAPサーバーにアクセスするポート番号をして指定します。' \
      '指定しない場合は既定値(LDAPは389、LDAPSは636)を使用します。',
          type: :integer,
          required: false,
          placeholder: '389 or 636',
        }, {
          name: :protocol,
          label: 'プロトコル',
          description:
      'LDAPサーバーにアクセスするプロトコルを指定します。' \
      'LDAPSを使用することを強く推奨します。',
          type: :string,
          default: 'ldaps',
          list: [
            {name: :ldap, label: 'LDAP(平文)', value: 'ldap', deprecated: true},
            {name: :ldap_starttls, label: 'LDAP(STARTTLS)', value: 'ldap_starttls'},
            {name: :ldaps, label: 'LDAPS(TLS)', value: 'ldaps'},
          ],
        }, {
          name: :certificate_check,
          label: '証明書チェックを行う。',
          description:
      'サーバー証明書のチェックを行います。LDAPサーバーには正式証明書が必要になります。',
          type: :boolean,
          default: true,
        }, {
          name: :base_dn,
          label: 'ベースDN',
          description: '全てベースです。',
          type: :string,
          placeholder: 'dc=example,dc=jp',
        }, {
          name: :bind_username,
          label: '接続ユーザー名',
          type: :string,
          placeholder: 'cn=Admin,dc=example,dc=jp',
        }, {
          name: :bind_password,
          label: '接続ユーザーのパスワード',
          type: :string,
          encrypted: true,
          input: 'password',
        }, {
          name: :user_name_attr,
          label: 'ユーザー名の属性',
          type: :string,
          placeholder: 'cn',
        }, {
          name: :user_base,
          label: 'ユーザー検索のベース',
          description: 'ユーザー検索を行うときのツリーベースです。指定しない場合はLDAPサーバーのベースから検索します。',
          type: :string,
          required: false,
          placeholder: 'ou=Users,dc=example,dc=jp',
        }, {
          name: :user_scope,
          label: 'ユーザー検索のスコープ',
          description: 'ユーザー検索を行うときのスコープです。デフォルトは sub です。',
          type: :string,
          default: 'sub',
          list: [
            {name: :base, label: 'ベースのみ検索(base)', value: 'base'},
            {name: :one, label: 'ベース直下のみ検索(one)', value: 'one'},
            {name: :sub, label: 'ベース配下全て検索(sub)', value: 'sub'},
          ],
        }, {
          name: :user_filter,
          label: 'ユーザー検索のフィルター',
          description:
      'ユーザー検索を行うときのフィルターです。' \
      'LDAPの形式で指定します。' \
      '何も指定しない場合は(objectclass=*)になります。',
          type: :string,
          required: false,
        }, {

          name: :password_scheme,
          label: 'パスワードのスキーム',
          description:
      'パスワード設定時に使うスキームです。' \
      '{CRYPT}はソルトフォーマットも選択してください。' \
      '対応するスキームはLDAPサーバーの実装によります。',
          type: :string,
          required: true,
          default: '{CRYPT}',
          list: [
            {name: :cleartext, label: '{CLEARTEXT} 平文', value: '{CLEARTEXT}', deprecated: true},
            {name: :crypt, label: '{CRYPT} CRYPT', value: '{CRYPT}'},
            {name: :md5, label: '{MD5} MD5', value: '{MD5}', deprecated: true},
            {name: :sha, label: '{SHA} SHA-1', value: '{SHA}', deprecated: true},
            {name: :sha256, label: '{SHA256} SHA-256', value: '{SHA256}', deprecated: true},
            {name: :sha512, label: '{SHA512} SHA-512', value: '{SHA512}', deprecated: true},
            {name: :smd5, label: '{SMD5} ソルト付MD5', value: '{SMD5}', deprecated: true},
            {name: :ssha, label: '{SSHA} ソルト付SHA-1', value: '{SSHA}', deprecated: true},
            {name: :ssha256, label: '{SSHA256} ソルト付-SHA256', value: '{SSHA256}'},
            {name: :ssha512, label: '{SSHA512} ソルト付SHA-512', value: '{SSHA512}'},
            {name: :pbkdf2_sha1, label: '{PBKDF2-SHA1} PBKDF2 SHA-1', value: '{PBKDF2-SHA1}', deprecated: true},
            {name: :pbkdf2_sha256, label: '{PBKDF2-SHA256} PBKDF2 SHA256', value: '{PBKDF2-SHA256}'},
            {name: :pbkdf2_sha512, label: '{PBKDF2-SHA512} PBKDF2 SHA256', value: '{PBKDF2-SHA512}'},
          ],
        }, {
          name: :crypt_salt_format,
          label: 'CRYPTのソルトフォーマット',
          description:
      'パスワードのスキームに{CRYPT}を使用している場合は、' \
      '記載のフォーマットでソルト値が作成されます。' \
      '対応する形式はサーバーのcryptの実装によります。',
          type: :string,
          default: '$6$%.16s',
          list: [
            {name: :des, label: 'DES', value: '%.2s', deprecated: true},
            {name: :md5, label: 'MD5', value: '$1$%.8s', deprecated: true},
            {name: :sha256, label: 'SHA256', value: '$5$%.16s'},
            {name: :sha512, label: 'SHA512', value: '$6$%.16s'},
          ],
        }
      ]

      def self.selectable?
        true
      end

      def check
        base = ldap.search(
          base: @params[:base_dn],
          scope: Net::LDAP::SearchScope_BaseObject)&.first
        if base
          true
        else
          false
        end
      end

      # def create(username, password = nil, **attrs)
      #   raise NotImplementedError
      # end

      def read(username)
        user = ldap.search(search_user_opts(username))&.first
        normalize_user(user)
      end

      # def udpate(username, **attrs)
      #   raise NotImplementedError
      # end

      # def delete(username)
      #   raise NotImplementedError
      # end

      def auth(username, password)
        opts = search_user_opts(username).merge(password: password)
        # bind_as is re bind, so DON'T USE `ldap`
        user = generate_ldap.bind_as(opts)
        normalize_user(user&.first) if user
      end

      def change_password(username, password)
        user = ldap.search(search_user_opts(username))&.first
        return nil unless user

        operations = change_password_operations(password, user.attribute_names)

        result = ldap.modify(dn: user.dn, operations: operations)
        raise ldap.get_operation_result.error_message unless result

        read(username)
      end

      def list
        generate_ldap.search(search_user_opts('*')).map do |user|
          user[@params[:user_name_attr]]&.first
        end
      end

      private def change_password_operations(password, existing_attrs = [])
        operations = []

        operations << generate_operation_replace(:userpassword, generate_password(password))

        if @params[:samba_password]
          operations << generate_operation_replace(:sambantpassword, generate_nt_password(password))
          operations << generate_operation_delete(:sambalmpassword) if existing_attrs.include?(:sambalmpassword)
        end

        operations
      end

      private def generate_operation(operator, name, value = nil)
        raise "invalid operator: #{operator}" unless [:add, :replace, :delete].include?(operator)

        [operator, name, value]
      end

      private def generate_operation_add(name, value)
        generate_operation(:add, name, value)
      end

      private def generate_operation_replace(name, value)
        generate_operation(:replace, name, value)
      end

      private def generate_operation_delete(name)
        generate_operation(:delete, name, nil)
      end

      private def ldap
        @ladp ||= generate_ldap
      end

      private def generate_ldap
        opts = {
          host: @params[:host],
          port: @params[:port],
          base: @params[:base_dn],
          auth: {
            method: :simple,
            username: @params[:bind_username],
            password: @params[:bind_password],
          },
        }

        port = @params[:port] if @params[:port] && !@params[:port].zero?
        case @params[:protocol]
        when 'ldap'
          opts[:port] = port || 389
        when 'ldaps'
          opts[:port] = port || 636
          opts[:encryption] =
            if @params[:certificate_check]
              :simple_tls
            else
              {
                method: :simple_tls,
                tls_options: {
                  verify_mode: OpenSSL::SSL::VERIFY_NONE,
                },
              }
            end
        else
          raise "invalid protcol: #{@params[:protocol]}"
        end

        Net::LDAP.new(opts)
      end

      private def search_user_opts(name)
        opts = {}
        if @params[:user_base] && !@params[:user_base].empty?
          opts[:base] = @params[:user_base] if @params[:user_base]
        else
          opts[:base] = @params[:base_dn]
        end
        opts[:scope] =
          case @params[:user_scope]
          when 'base' then Net::LDAP::SearchScope_BaseObject
          when 'one' then Net::LDAP::SearchScope_SingleLevel
          when 'sub' then Net::LDAP::SearchScope_WholeSubtree
          else raise 'Invalid scope'
          end

        common_filter =
          if @params[:user_filter] && !@params[:user_filter].empty?
            Net::LDAP::Filter.construct(@params[:user_filter])
          else
            Net::LDAP::Filter.pres('objectclass')
          end

        opts[:filter] = common_filter &
                        Net::LDAP::Filter.eq(@params[:user_name_attr], name)

        opts
      end

      private def normalize_user(user)
        return if user.nil?

        data = {
          name: user[@params[:user_name_attr]]&.first,
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

      # https://trac.tools.ietf.org/id/draft-stroeder-hashed-userpassword-values-00.html
      private def generate_password(password)
        case @params[:password_scheme]
        when '{CLEARTEXT}'
          password
        when '{CRYPT}'
          # 16 [./0-9A-Za-z] chars
          salt = SecureRandom.base64(12).tr('+', '.')
          "{CRYPT}#{password.crypt(format(@params[:crypt_salt_format], salt))}"
        when '{MD5}'
          "{MD5}#{Base64.strict_encode64(Digest::MD5.digest(password))}"
        when '{SHA}'
          "{SHA}#{Base64.strict_encode64(Digest::SHA1.digest(password))}"
        when '{SHA256}'
          "{SHA256}#{Base64.strict_encode64(Digest::SHA256.digest(password))}"
        when '{SHA512}'
          "{SHA512}#{Base64.strict_encode64(Digest::SHA512.digest(password))}"
        when '{SMD5}'
          salt = SecureRandom.random_bytes(8)
          "{SMD5}#{Base64.strict_encode64(Digest::MD5.digest(password + salt), salt)}"
        when '{SSHA}'
          salt = SecureRandom.random_bytes(8)
          "{SSHA}#{Base64.strict_encode64(Digest::SHA1.digest(password + salt), salt)}"
        when '{SSHA256}'
          salt = SecureRandom.random_bytes(8)
          "{SSHA256}#{Base64.strict_encode64(Digest::SHA256.digest(password + salt), salt)}"
        when '{SSHA512}'
          salt = SecureRandom.random_bytes(8)
          "{SSHA512}#{Base64.strict_encode64(Digest::SHA512.digest(password + salt), salt)}"
        else
          # TODO: PBKDF2
          raise NotImplementedError
        end
      end

      private def lock_password(str)
        if (m = /\A({[\w-]+})(.*)\z/.match(str))
          "#{m[1]}!#{m[2]}"
        else
          # 不正なパスワード
          '{!}!'
        end
      end

      private def unlock_password(str)
        if (m = /\A({[\w-]+})!(.*)\z/.match(str))
          m[1] + m[2]
        else
          str
        end
      end
    end
  end
end
