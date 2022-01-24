require 'securerandom'
require 'base64'
require 'digest'

# パスワード変更について
# userPassword は {CRYPT}$6$%.16s をデフォルトする。

require_relative 'ldap_base_adapter'

module Yuzakan
  module Adapters
    class LdapAdapter < LdapBaseAdapter
      self.abstract_adapter = true

      self.label = 'LDAP'

      self.params = ha_merge(*LdapBaseAdapter.params, {
        name: :password_scheme,
        label: 'パスワードのスキーム',
        description: 'パスワード設定時に使うスキームです。' \
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
        description: 'パスワードのスキームに{CRYPT}を使用している場合は、' \
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
      })

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
