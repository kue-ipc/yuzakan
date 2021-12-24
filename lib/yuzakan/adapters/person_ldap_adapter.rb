require 'securerandom'
require 'net/ldap'
require 'smbhash'

# inetOrgPerson and memberOf

require_relative 'ldap_adapter'

module Yuzakan
  module Adapters
    class PersonLdapAdapter < LdapAdapter
      LABEL = 'Person LDAP'

      PARAMS = PARAM_TYPES = LdapAdapter::PARAM_TYPES(+[
        {
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
      ])

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

      def list
        generate_ldap.search(search_user_opts('*')).map do |user|
          user[@params[:user_name_attr]]&.first
        end
      end

      private def change_password_operations(password)
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

      # 現在のところ CRYPT-MD5のみ実装
      # slappasswd -h '{CRYPT}' -c '$1$%.8s'
      # $1$vuIZLw8r$d9mkddv58FuCPxOh6nO8f0
      private def generate_password(password)
        salt = SecureRandom.base64(12).gsub('+', '.')
        "{CRYPT}#{password.crypt(format('$1$%.8s', salt))}"
      end

      private def generate_nt_password(password)
        Smbhash.ntlm_hash(password)
      end

      # 14文字までしか対応できない
      private def generate_lm_password(password)
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
