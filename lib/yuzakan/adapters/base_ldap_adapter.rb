require 'securerandom'
require 'net/ldap'

require 'base64'
require 'digest'

# パスワード変更について
# userPassword は {crypt}$1$%.8s をデフォルトする。
# sambaLMPassword はデフォルト無効とし、設定済みは削除する。
# sambaNTPassword はデフォルト有効とし、設定する。

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class BaseLdapAdapter < AbstractAdapter
      self.abstract_adapter = true

      self.params = [
        {
          name: :host,
          label: 'サーバーのホスト名/IPアドレス',
          description: 'LDAPサーバーのホスト名またはIPアドレスを指定します。',
          type: :string,
          placeholder: 'ldap.example.jp',
        }, {
          name: :port,
          label: 'ポート',
          description: 'LDAPサーバーにアクセスするポート番号をして指定します。' \
                       '指定しない場合は既定値(LDAPは389、LDAPSは636)を使用します。',
          type: :integer,
          required: false,
          placeholder: '389 or 636',
        }, {
          name: :protocol,
          label: 'プロトコル/暗合形式',
          description: 'LDAPサーバーにアクセスするプロトコルを指定します。',
          type: :string,
          default: 'ldaps',
          list: [
            {name: :ldap, label: 'LDAP(平文)', value: 'ldap', deprecated: true},
            {name: :ldap_starttls, label: 'LDAP+STARTTLS(暗合)', value: 'ldap_starttls'},
            {name: :ldaps, label: 'LDAPS(暗合)', value: 'ldaps'},
          ],
          input: 'radio',
        }, {
          name: :certificate_check,
          label: '証明書チェックを行う。',
          description: 'サーバー証明書のチェックを行います。' \
                       'LDAPサーバーには正式証明書が必要になります。',
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
          name: :user_dn_attr,
          label: 'ユーザーDNの属性',
          type: :string,
          placeholder: 'cn',
        }, {
          name: :user_ou_dn,
          label: 'ユーザーのOU',
          description: 'ユーザー作成するときのOUです。' \
                       '指定しない場合はLDAPサーバーのベースから検索します。',
          type: :string,
          required: false,
          placeholder: 'ou=Users',
        }, {
          name: :user_name_attr,
          label: 'ユーザー名の属性',
          type: :string,
          placeholder: 'cn',
        }, {
          name: :user_display_name_attr,
          label: 'ユーザー表示名の属性',
          type: :string,
          default: 'displayName;lang-ja',
          placeholder: 'displayName;lang-ja',
        }, {
          name: :user_email_attr,
          label: 'ユーザーメールの属性',
          type: :string,
          default: 'mail',
          placeholder: 'mail',
        }, {
          name: :user_search_base_dn,
          label: 'ユーザー検索のベースDN',
          description: 'ユーザー検索を行うときのベースです。' \
                       '指定しない場合はLDAPサーバーのベースから検索します。',
          type: :string,
          required: false,
          placeholder: 'ou=Users',
        }, {
          name: :user_search_scope,
          label: 'ユーザー検索のスコープ',
          description: 'ユーザー検索を行うときのスコープです。' \
                       '通常は sub を使用します。',
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
        },
      ]

      class << self
        attr_accessor :multi_attrs
      end

      self.multi_attrs = %w[objectClass]

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

      def create(username, password = nil, **attrs)
        return nil if read(username)

        user_data = attrs.filter { |key, _| key.is_a?(String) }.transform_keys { |key| attribute_name(key) }
        user_data[attribute_name(@params[:user_name_attr])] = attrs[:username]
        user_data[attribute_name(@params[:user_display_name_attr])] = attrs[:display_name] if attrs[:display_name]
        user_data[attribute_name(@params[:user_email_attr])] = attrs[:email] if attrs[:email]

        dn = "#{@params[:user_dn_attr]}=#{ldap_attrs[@params[:user_dn_attr].intern]},#{@params[:user_base]}"

        raise ldap.get_operation_result.error_message unless ldap.add(dn: dn, attributes: user_data)

        change_password(username, password) if password

        read(username)
      end

      def read(username)
        opts = search_user_opts(username)
        result = ldap.search(opts)
        normalize_user_attrs(result.first) if result
      end

      def udpate(username, **attrs)
        raise NotImplementedError
      end

      # def delete(username)
      #   raise NotImplementedError
      # end

      def auth(username, password)
        opts = search_user_opts(username).merge(password: password)
        # bind_as is re bind, so DON'T USE `ldap`
        result = generate_ldap.bind_as(opts)
        normalize_user_attrs(result&.first) if result
      end

      def change_password(username, password)
        user_attrs = read(username)
        return nil unless user_attrs

        operations = change_password_operations(password)

        modify_result = ldap.modify(dn: user_attrs['dn'], operations: operations)
        raise ldap.get_operation_result.error_message unless modify_result

        user_attrs
      end

      def list
        generate_ldap.search(search_user_opts('*')).map do |user|
          user[@params[:user_name_attr]]&.first
        end
      end

      private def change_password_operations(_password)
        raise NotImplementedError
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
        opts[:encryption] = {}
        case @params[:protocol]
        when 'ldap'
          opts[:port] = port || 389
        when 'ldap_starttls'
          opts[:port] = port || 389
          opts[:encryption][:method] = :start_tls
        when 'ldaps'
          opts[:port] = port || 636
          opts[:encryption][:method] = :simple_tls
        else
          raise "invalid protcol: #{@params[:protocol]}"
        end

        opts[:encryption][:tls_options] = {verify_mode: OpenSSL::SSL::VERIFY_NONE} unless @params[:certificate_check]

        Net::LDAP.new(opts)
      end

      private def search_user_opts(name, base: @params[:user_base] || @params[:base_dn],
                                   scope: @params[:user_scope], filter: @params[:user_filter])
        opts = {}

        opts[:base] = base

        opts[:scope] =
          case scope
          when 'base' then Net::LDAP::SearchScope_BaseObject
          when 'one' then Net::LDAP::SearchScope_SingleLevel
          when 'sub' then Net::LDAP::SearchScope_WholeSubtree
          else raise 'Invalid scope'
          end

        common_filter =
          if filter
            Net::LDAP::Filter.construct(@params[:user_filter])
          else
            Net::LDAP::Filter.pres('objectClass')
          end

        opts[:filter] = common_filter &
                        Net::LDAP::Filter.eq(@params[:user_name_attr], name)

        opts
      end

      private def normalize_user_attrs(entry)
        attrs = {
          name: entry.first(@params[:user_name_attr]),
          display_name: entry.first(@params[:user_display_name_attr]),
          email: entry.first(@params[:user_email_attr]),
        }

        entry.each do |name, value|
          attrs[name.to_s] =
            if self.class.multi_attrs.include?(name)
              value
            else
              value.first
            end
        end

        attrs
      end

      private def attribute_name(name)
        Net::LDAP::Entry.attribute_name(name)
      end

      # https://trac.tools.ietf.org/id/draft-stroeder-hashed-userpassword-values-00.html
      private def generate_password(password)
        case @params[:password_scheme].upcase
        when '{CLEARTEXT}'
          password
        when '{CRYPT}'
          # 16 [./0-9A-Za-z] chars
          salt = SecureRandom.base64(12).tr('+', '.')
          "{CRYPT}#{generate_crypt_password(password)}"
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

      private def generate_crypt_password(password, format: @params[:crypt_salt_format])
        salt = SecureRandom.base64(12).tr('+', '.')
        password.crypt(format % salt)
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