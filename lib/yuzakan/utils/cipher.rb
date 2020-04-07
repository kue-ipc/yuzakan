# frozen_string_literal: true

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
    module Cipher
      DEFULT_ALGO = 'aes-256-cbc'
      DEFAULT_ITER = 10_000
      DEFAULT_SALT_SIZE = 8

      module_function

      def encrypt_text(text, **opts)
        return String.new if text.empty?

        Base64.strict_encode64(encrypt(text, **opts))
      end

      def decrypt_text(encrypted_text, encoding: 'utf-8', **opts)
        return String.new(encoding: encoding) if encrypted_text.empty?

        decrypt(Base64.strict_decode64(encrypted_text), **opts)
          .force_encoding(encoding)
      end

      def encrypt(data, algo: DEFULT_ALGO, iter: DEFAULT_ITER,
                  salt_size: DEFAULT_SALT_SIZE)
        return String.new if data.empty?

        salt = generate_salt(salt_size)

        enc = OpenSSL::Cipher.new(algo)
        enc.encrypt

        key, iv = generate_key_iv(enc, secret_password, salt, iter)
        enc.key = key
        enc.iv = iv

        encrypted_data = String.new
        encrypted_data << enc.update(data)
        encrypted_data << enc.final
        salt + encrypted_data
      end

      def decrypt(salt_encrypted_data, algo: DEFULT_ALGO, iter: DEFAULT_ITER,
                  salt_size: DEFAULT_SALT_SIZE)
        return String.new if salt_encrypted_data.empty?

        dec = OpenSSL::Cipher.new(algo)
        dec.decrypt
        salt = salt_encrypted_data[0, salt_size]
        encrypted_data = salt_encrypted_data[salt_size..]

        key, iv = generate_key_iv(dec, secret_password, salt, iter)
        dec.key = key
        dec.iv = iv

        data = String.new
        data << dec.update(encrypted_data)
        data << dec.final
        data
      end

      def generate_key_iv(cipher, pass, salt, iter)
        key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(pass, salt, iter,
                                                 cipher.key_len + cipher.iv_len)
        key = key_iv[0, cipher.key_len]
        iv = key_iv[cipher.key_len, cipher.iv_len]
        [key, iv]
      end

      def generate_salt(size)
        SecureRandom.random_bytes(size)
      end

      def secret_password
        ENV.fetch('DB_SECRET')
      end
    end
  end
end
