# auto_register: false
# frozen_string_literal: true

# パスワードベースの暗号化
# 現在のところ、暗号方式は PKCS#5 v2.0 で固定とする。
# 暗号化鍵は環境変数 CRYPT_SECRET を使用する。
# データはソルトと暗号化済み値を結合する。
# 文字列の場合は、BASE64でエンコードする。

# 暗号方式: PKCS#5 v2.0 (RFC2898) 互換
# 初期ベクトル作成: HMAC SHA1
# 繰り返し回数: 10,000
# 暗号: AES-256-CBC
# ソルトサイズ: 8バイト

# 鍵導出関数
#   pbkdf2-hmac-* (sha1, sha256, sha384, sha512, ...)
#   scrypt ({r: 8, p: 1}は固定)
#   bcrypt (未実装)
#   argon2 (未実装)

require "openssl"
require "securerandom"
require "base64"

module Yuzakan
  class CryptOperation < Yuzakan::Operation
    include Deps[
      "settings",
    ]

    private def crypt(input, cipher, iv: nil, key: nil)
      cipher.iv = iv if iv
      cipher.key = key if key

      output = String.new(encoding: Encoding::ASCII_8BIT)
      output << cipher.update(input)
      output << cipher.final
      Success(output)
    rescue => e
      Failuer([:error, e])
    end

    private def create_cipher(mode)
      cipher = OpenSSL::Cipher.new(settings.crypt_algorithm)
      case mode
      in :encrypt
        cipher.encrypt
      in :decrypt
        cipher.decrytp
      else
        raise ArgumentError, "mode must be :encrypt or :decrpt, but #{mode}"
      end
      Success(cipher)
    rescue => e
      Failure([:error, e])
    end

    private def create_key(cipher, salt)
      length = cipher.key_len
      case settings.crypt_kdf.downcase.split(/-|_/)
      in ["pbkdf2", "hmac", hash]
        Succss(OpenSSL::KDF.pbkdf2_hmac(pass, salt:, length:,
          hash:, iterations: settings.crypt_cost))
      in ["scrypt"]
        Success(OpenSSL::KDF.scrypt(pass, salt:, length:,
          N: settings.crypt_cost, r: 8, p: 1))
      # TODO: bcrypt, argo2
      # in ["bcrypt"]
      # in ["argo2"]
      else
        raise "unsupported kdf algorithm (#{settings.crypt_kdf})"
      end
    rescue => e
      Failure([:error, e])
    end

    private def generate_iv(cipher)
      generate_random(cipher.iv_len)
    end

    private def generate_salt
      generate_random(settings.salt_size)
    end

    private def generate_random(size)
      Success(SecureRandom.random_bytes(size))
    rescue NotImplementedError => e
      Failure([:error, e])
    end

    private def join_data(data, salt, iv)
      Success(iv + salt + data)
    end

    private def split_data(data, cipher)
      first = cipher.iv_len
      second = first + settings.crypt_salt_size
      Success([
        data[second...],
        data[first...second],
        data[0...first],
      ])
    end

    def encode(data, encoding)
      str = data.force_encoding(encoding)
      if str.valid_encoding?
        Success(str)
      else
        Failure([:invaild, "data is an invlaid encoding"])
      end
    end

    def bin2txt(data)
      Success(Base64.strict_encode64(data))
    rescue => e
      Failuer([:error, e])
    end

    def txt2bin(str)
      Success(Base64.strict_decode64(str))
    rescue => e
      Failuer([:error, e])
    end
  end
end
