require 'securerandom'
require 'net/ldap'
require 'smbhash'

# パスワード変更について
# userPassword は {CRYPT}$1$%.8s をデフォルトする。
# sambaLMPassword はデフォルト無効とし、設定済みは削除する。
# sambaNTPassword はデフォルト有効とし、設定する。

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class LdapAdapter < AbstractAdapter
      def self.label
        'LDAP'
      end

      def self.selectable?
        true
      end

      self.params = [
        {
          name: 'host',
          label: 'サーバーのホスト名/IPアドレス',
          description:
            'LDAPサーバーのホスト名またはIPアドレスを指定します。',
          type: :string,
          required: true,
          placeholder: 'ldap.example.jp',
        }, {
          name: 'port',
          label: 'ポート',
          description:
            'LDAPサーバーにアクセスするポート番号をして指定します。' \
            '指定しない場合は既定値(LDAPは389、LDAPSは636)を使用します。',
          type: :integer,
          required: false,
          placeholder: '636',
        }, {
          name: 'protocol',
          label: 'プロトコル',
          description:
            'LDAPサーバーにアクセスするプロトコルを指定します。' \
            'LDAPSを使用することを強く推奨します。',
          type: :string,
          required: true,
          list: [
            {
              name: 'LDAP(平文)',
              value: 'ldap',
            }, {
              name: 'LDAPS(暗号化)',
              value: 'ldaps',
            },
          ],
          default: 'ldaps',
        }, {
          name: 'certificate_check',
          label: '証明書チェックを行う。',
          description:
            'サーバー証明書のチェックを行います。LDAPサーバーには正式証明書が必要になります。。',
          type: :boolean,
          default: true,
        }, {
          name: 'base_dn',
          label: 'ベースDN',
          description: '全てベースです。',
          type: :string,
          required: false,
          placeholder: 'dc=example,dc=jp',
        }, {
          name: 'bind_username',
          label: '接続ユーザー名',
          type: :string,
          required: true,
          placeholder: 'cn=Admin,dc=example,dc=jp',
        }, {
          name: 'bind_password',
          label: '接続ユーザーのパスワード',
          type: :string,
          input: 'password',
          required: true,
          encrypted: true,
        }, {
          name: 'user_name_attr',
          label: 'ユーザー名の属性',
          type: :string,
          required: true,
          placeholder: 'cn',
        }, {
          name: 'user_base',
          label: 'ユーザー検索のベース',
          description: 'ユーザー検索を行うときのツリーベースです。指定しない場合はLDAPサーバーのベースから検索します。',
          type: :string,
          required: false,
          placeholder: 'ou=Users,dc=example,dc=jp',
        }, {
          name: 'user_scope',
          label: 'ユーザー検索のスコープ',
          description: 'ユーザー検索を行うときのスコープです。デフォルトは sub です。',
          type: :string,
          required: true,
          list: [
            {
              name: 'ベースのみ検索(base)',
              value: 'base',
            }, {
              name: 'ベース直下のみ検索(one)',
              value: 'one',
            }, {
              name: 'ベース配下全て検索(sub)',
              value: 'sub',
            },
          ],
          default: 'sub',
        }, {
          name: 'user_filter',
          label: 'ユーザー検索のフィルター',
          description:
            'ユーザー検索を行うときのフィルターです。' \
            'LDAPの形式で指定します。' \
            '何も指定しない場合は(objectclass=*)になります。',
          type: :string,
          required: false,
        }, {
          name: 'password_scheme',
          label: 'パスワードのスキーム',
          description:
            'パスワード設定時に使うスキームです。{CRYPT}はソルトフォーマットも選択してください。',
          type: :string,
          required: true,
          list: [
            {
              name: '{SHA} SHA-1 (非推奨)',
              value: '{SHA}',
            }, {
              name: '{SSHA} ソルト付SHA-1',
              value: '{SSHA}',
            }, {
              name: '{MD5} MD5 (非推奨)',
              value: '{MD5}',
            }, {
              name: '{SMD5} ソルト付MD5',
              value: '{SMD5}',
            }, {
              name: '{CRYPT} CRYPT (ソルトフォーマットも記入してください)',
              value: '{CRYPT}',
            }, {
              name: '平文 (非推奨)',
              value: '{CLEARTEXT}',
            },
          ],
          default: '{CRYPT}',
        }, {
          name: 'crypt_salt_format',
          label: 'CRYPTのソルトフォーマット',
          description:
            'パスワードのスキームに{CRYPT}を使用している場合は、' \
            '記載のフォーマットでソルト値が作成されます。' \
            '作成できる形式はサーバーのcryptの実装によります。' \
            '何も指定しない場合はCRYPT-MD5("$1$%.8s")を使用します。',
          type: :string,
          required: false,
        }, {
          name: 'samba_password',
          label: 'Sambaパスワード設定',
          description:
            'パスワード設定時にSambaパスワードも設定します。ただし、LMパスワードは設定しません。',
          type: :boolean,
          default: false,
        },
      ]

      def check
        puts '-----------------'
        ldap = generate_ldap
        puts @params
        puts ldap.search(
          base: @params[:base_dn],
          scope: Net::LDAP::SearchScope_BaseObject)
        base = ldap.search(
          base: @params[:base_dn],
          scope: Net::LDAP::SearchScope_BaseObject)&.first
        if base
          true
        else
          false
        end
      end

      # def create(username, attrs, mappings = nil)
      #   raise NotImplementedError
      # end

      def read(username, mappings = nil)
        ldap = generate_ldap
        user = ldap.search(search_user_opts(username))&.first
        normalize_user(user, mappings)
      end

      # def udpate(username, attrs, mappings = nil)
      #   raise NotImplementedError
      # end

      # def delete(username)
      #   raise NotImplementedError
      # end

      def auth(username, password)
        ldap = generate_ldap
        opts = search_user_opts(username).merge(password: password)
        user = ldap.bind_as(opts)
        normalize_user(user&.first) if user
      end

      def change_password(username, password)
        ldap = generate_ldap
        user = ldap.search(search_user_opts(username))&.first
        return false unless user

        operations = []

        operations <<
          if user[:userpassword]&.first
            [
              :replace,
              :userpassword,
              [generate_password(password)],
            ]
          else
            [
              :add,
              :userpassword,
              generate_password(password),
            ]
          end

        if @params[:samba_password]
          operations <<
            if user[:sambantpassword]&.first
              [
                :replace,
                :sambantpassword,
                [generate_ntpassword(password)],
              ]
            else
              [
                :add,
                :sambantpassword,
                generate_ntpassword(password),
              ]
            end

          if user[:sambalmpassword]&.first
            operations << [:delete, :sambalmpassword, nil]
          end
        end

        result = ldap.modify(
          dn: user.dn,
          operations: operations)
        raise ldap.get_operation_result.error_message unless result

        result
      end

      def list
        generate_ldap.search(search_user_opts('*')).map do |user|
          user[@params[:user_name_attr]]&.first
        end
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

      private def normalize_user(user, mappings = nil)
        return if user.nil?

        data = {
          name: user[@params[:user_name_attr]]&.first,
          display_name: user[:'displayname;lang-ja']&.first ||
                        user[:displayname]&.first ||
                        user[@params[:user_name_attr]]&.first,
          email: user[:email]&.first || user[:mail]&.first,
        }

        if mappings
          mappings.each do |mapping|
            value = user[mapping.name.downcase.intern]&.first
            next if value.nil?

            data[mapping.attr.name.intern] = mapping.convert(value)
          end
        end

        data
      end

      # 現在のところ CRYPT-MD5のみ実装
      # slappasswd -h '{CRYPT}' -c '$1$%.8s'
      # $1$vuIZLw8r$d9mkddv58FuCPxOh6nO8f0
      private def generate_password(password)
        salt = SecureRandom.base64(12).gsub('+', '.')
        "{CRYPT}#{password.crypt(format('$1$%.8s', salt))}"
      end

      private def generate_ntpassword(password)
        Smbhash.ntlm_hash(password)
      end

      # TODO: 14文字までしか対できない
      private def generate_lmpassword(password)
        Smbhash.lm_hash(password)
      end

      private def lock_password(str)
        if (m = /\A({[A-Z]+})(.*)\z/.match(str))
          "#{m[1]}!#{m[2]}"
        else
          # 不正なパスワード
          '{!}!'
        end
      end

      private def unlock_password(str)
        if (m = /\A({[A-Z]+})!(.*)\z/.match(str))
          m[1] + m[2]
        else
          str
        end
      end
    end
  end
end
