# auto_register: false
# frozen_string_literal: true

# パスワードベースの暗号化
# 暗号化鍵は環境変数 CRYPT_SECRET を使用する。
# データはソルト、IV、認証タグ、暗号化済み値を結合する。
# 文字列の場合は、BASE64でエンコードする。
# デフォルト: aes-256-gcm scrypt 2*17
# 認証付き暗号では、`auth_data`と`auth_tag_len`は固定値。

require "openssl"
require "base64"

module Yuzakan
  class CryptOperation < Yuzakan::Operation
    include Deps[
      "settings",
    ]

    AUTH_DATA = "yuzakan"
    AUTH_TAG_LEN = 16

    private def crypt_data(cipher, data)
      Success(cipher.update(data) + cipher.final)
    rescue OpenSSL::Cipher::CipherError => e
      Failure([:error, e])
    end

    private def create_cipher(mode)
      cipher = OpenSSL::Cipher.new(settings.crypt_algorithm)
      case mode
      in :encrypt
        cipher.encrypt
      in :decrypt
        cipher.decrypt
      else
        raise ArgumentError, "mode must be :encrypt or :decrpt, but #{mode}"
      end
      Success(cipher)
    rescue => e
      Failure([:error, e])
    end

    # 鍵導出関数 CRYPT_SECRET
    #   pbkdf2-hmac-* (sha1, sha256, sha384, sha512)
    #   scrypt ({r: 8, p: 1}は固定)
    #   bcrypt (未実装)
    #   argon2 (未実装)
    private def setup_key(cipher, key: nil, salt: nil, secret: nil, **info)
      if key.nil?
        secret ||= settings.crypt_secret
        salt ||= generate_salt.value_or { return Failure(_1) }
        length = cipher.key_len
        key =
          case settings.crypt_kdf.downcase.split(/-|_/)
          in ["pbkdf2", "hmac", hash]
            OpenSSL::KDF.pbkdf2_hmac(secret, salt:, length:,
              hash:, iterations: settings.crypt_cost)
          in ["scrypt"]
            OpenSSL::KDF.scrypt(secret, salt:, length:,
              N: settings.crypt_cost, r: 8, p: 1)
          # TODO: bcrypt, argo2
          # in ["bcrypt"]
          # in ["argo2"]
          else
            raise "unsupported kdf algorithm (#{settings.crypt_kdf})"
          end
      end
      cipher.key = key
      Success({**info, key:, salt:, secret:})
    rescue => e
      # RuntimeError, OpenSSL::Cipher::CipherError, etc...
      Failure([:error, e])
    end

    private def setup_iv(cipher, iv: nil, **info)
      if iv
        cipher.iv = iv
      else
        iv = cipher.random_iv
      end
      Success({**info, iv:})
    rescue OpenSSL::Cipher::CipherError => e
      Failure([:error, e])
    end

    private def setup_auth_data(cipher, auth_data: nil, **info)
      if cipher.authenticated?
        auth_data ||= AUTH_DATA
        cipher.auth_data = auth_data
      end
      Success({**info, auth_data:})
    rescue OpenSSL::Cipher::CipherError => e
      Failure([:error, e])
    end

    private def setup_auth_tag(cipher, auth_tag: nil, **info)
      if cipher.authenticated?
        if auth_tag
          cipher.auth_tag = auth_tag
        else
          auth_tag = cipher.auth_tag
        end
      end
      Success({**info, auth_tag:})
    rescue OpenSSL::Cipher::CipherError => e
      Failure([:error, e])
    end

    private def generate_salt(size = settings.crypt_salt_size)
      Success(OpenSSL::Random.random_bytes(size))
    rescue NotImplementedError => e
      Failure([:error, e])
    end

    private def join_data(data, salt: nil, iv: nil, auth_tag: nil, **_info)
      joined_data = String.new
      joined_data << salt if salt
      joined_data << iv if iv
      joined_data << auth_tag if auth_tag
      joined_data << data
      Success(joined_data)
    end

    private def split_data(data, cipher)
      salt_len = settings.crypt_salt_size
      iv_len = cipher.iv_len
      auth_tag_len = cipher.authenticated? ? AUTH_TAG_LEN : 0

      info = {
        salt: data[0, salt_len],
        iv: data[salt_len, iv_len],
        auth_tag: data[salt_len + iv_len, auth_tag_len],
      }
      Success([data[(salt_len + iv_len + auth_tag_len)..], info])
    end

    private def encode(data, encoding)
      str = data.force_encoding(encoding)
      if str.valid_encoding?
        Success(str)
      else
        Failure([:invaild, "data is an invlaid encoding"])
      end
    end

    private def bin2txt(data)
      Success(Base64.strict_encode64(data))
    rescue => e
      Failure([:error, e])
    end

    private def txt2bin(str)
      Success(Base64.strict_decode64(str))
    rescue => e
      Failure([:error, e])
    end
  end
end
