# PbCrypt: Password-Based Cryptography

# 現在のところ、暗号方式は PKCS#5 v2.0 で固定とする。
# 暗号化鍵は環境変数 DB_SECRET を使用する。
# データはソルトと暗号化済み値を結合し、BASE64でエンコードして保存する。

# 暗号方式: PKCS#5 v2.0 (RFC2898) 互換
# 初期ベクトル作成: HMAC SHA1
# 繰り返し回数: 10,000
# 暗号: AES-256-CBC
# ソルトサイズ: 8バイト

require 'openssl'
require 'securerandom'
require 'base64'

module Yuzakan
  module Utils
    class PbCrypt
      DEFAULT_ALGORITHM = 'aes-256-cbc'
      DEFAULT_ITERATION = 10_000
      DEFAULT_SALT_SIZE = 8

      def initialize(password,
                     algorithm: DEFAULT_ALGORITHM,
                     iteration: DEFAULT_ITERATION,
                     salt_size: DEFAULT_SALT_SIZE)
        @password = password
        @algorithm = algorithm
        @iteration = iteration
        @salt_size = salt_size
      end

      def encrypt_text(text)
        return '' if text.empty?

        Base64.strict_encode64(encrypt(text))
      end

      def decrypt_text(salt_encrypted_text, encoding: Encoding::UTF_8)
        return String.new(encoding: encoding) if salt_encrypted_text.empty?

        decrypt(Base64.strict_decode64(salt_encrypted_text))
          .force_encoding(encoding)
      end

      def encrypt(data)
        return '' if data.empty?

        salt = generate_salt

        enc = OpenSSL::Cipher.new(@algorithm)
        enc.encrypt

        key, iv = generate_key_iv(enc, salt)
        enc.key = key
        enc.iv = iv

        encrypted_data = String.new(encoding: Encoding::ASCII_8BIT)
        encrypted_data << enc.update(data)
        encrypted_data << enc.final
        salt + encrypted_data
      end

      def decrypt(salt_encrypted_data)
        return '' if salt_encrypted_data.empty?

        dec = OpenSSL::Cipher.new(@algorithm)
        dec.decrypt
        salt = salt_encrypted_data[0...@salt_size]
        encrypted_data = salt_encrypted_data[@salt_size..]

        key, iv = generate_key_iv(dec, salt)
        dec.key = key
        dec.iv = iv

        data = String.new(encoding: Encoding::ASCII_8BIT)
        data << dec.update(encrypted_data)
        data << dec.final
        data
      end

      def generate_key_iv(cipher, salt)
        key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(
          @password, salt, @iteration, cipher.key_len + cipher.iv_len)
        key = key_iv[0, cipher.key_len]
        iv = key_iv[cipher.key_len, cipher.iv_len]
        [key, iv]
      end

      def generate_salt
        SecureRandom.random_bytes(@salt_size)
      end
    end
  end
end
