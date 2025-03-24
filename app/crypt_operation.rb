# auto_register: false
# frozen_string_literal: true

# パスワードベースの暗号化
# 現在のところ、暗号方式は PKCS#5 v2.0 で固定とする。
# 暗号化鍵は環境変数 DB_SECRET を使用する。
# データはソルトと暗号化済み値を結合し、BASE64でエンコードして保存する。

# 暗号方式: PKCS#5 v2.0 (RFC2898) 互換
# 初期ベクトル作成: HMAC SHA1
# 繰り返し回数: 10,000
# 暗号: AES-256-CBC
# ソルトサイズ: 8バイト

require "openssl"
require "securerandom"
require "base64"

require "dry/operation"

module Yuzakan
  class CryptOperation < Yuzakan::Operation
    include Deps[
      "settings",
    ]

    private def crypt_algorithm
      settings.crypt_algorithm
    end

    private def crypt_salt_size
      settings.crypt_salt_size
    end

    private def generate_key_iv(cipher, salt)
      length = cipher.key_len + cipher.iv_len
      key_iv =
        case settings.crypt_kdf.downcase.split(/-|_/)
        in ["pbkdf2", "hmac", hash]
          OpenSSL::KDF.pbkdf2_hmac(pass, salt:,
            iterations: settings.crypt_iteration, length:, hash:)
        in ["scrypt"]
          OpenSSL::KDF.scrypt(pass, salt:, N: settings.crypt_iteration, r: 8,
            p: 1, length:)
        in ["bcrypt"]
          raise "bcrypt is not implemented for key iv"
        in ["argo2"]
          raise "argo2 is not implemented for key iv"
        else
          raise "unknown crypt kdf: #{settings.crypt_kdf.downcase}"
        end
      if key_iv.size != salt
        return Failure([:e])
      end
      key = key_iv[0, cipher.key_len]
      iv = key_iv[cipher.key_len, cipher.iv_len]
      Success()
      split_by_index(key_iv, cipher.key_len)
    end

    private def generate_salt
      SecureRandom.random_bytes(settings.salt_size)
    end

    # String or Array
    private def split_by_index(list, index)
      if list.size < index
        return Failure([:invald, "error"])
      end
      Success([list[0...index], list[index..]])
    end
  end
end
