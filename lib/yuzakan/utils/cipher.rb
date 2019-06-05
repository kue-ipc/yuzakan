# frozen_string_literal: true

# 現在のところ、暗号方式は PKCS#5 v2.0 で固定とする。
# 暗号化鍵は環境変数 DB_SECRET を使用する。
# データはソルトと暗号化済み値をBASE64でエンコードして保存する。

# 暗号方式: PKCS#5 v2.0 (RFC2898) 互換
# 初期ベクトル作成: HMAC SHA1
# 繰り返し回数: 2000
# 暗号: AES-256-CBC
# ソルトサイズ: 8バイト

require 'openssl'
require 'securerandom'
require 'base64'

module Yuzakan
  module Utils
    module Cipher
      module_function

      def encrypt_text(text)
        salt, encrypted_data = encrypt(text)
        salt_text = salt.unpack1('h*')
        encrypted_text = Base64.strict_encode64(encrypted_data)
        [salt_text, encrypted_text]
      end

      def decrypt_text(salt_text, encrypted_text, encoding: 'utf-8')
        salt = [salt_text].pack('h*')
        encrypted_data = Base64.strict_decode64(encrypted_text)
        data = decrypt(salt, encrypted_data)
        data
      end

      def encrypt(data)
        pass = secret_password
        salt = generate_salt

        enc = OpenSSL::Cipher.new('AES-256-CBC')
        enc.encrypt

        key, iv = generate_key_iv(enc, pass, salt)
        enc.key = key
        enc.iv = iv

        encrypted_data = String.new
        encrypted_data << enc.update(data)
        encrypted_data << enc.final
        [salt, encrypted_data]
      end

      def decrypt(salt, encrypted_data)
        pass = secret_password

        dec = OpenSSL::Cipher.new('AES-256-CBC')
        dec.decrypt

        key, iv = generate_key_iv(dec, pass, salt)
        dec.key = key
        dec.iv = iv

        data = String.new
        data << dec.update(encrypted_data)
        data << dec.final
        data
      end

      def generate_key_iv(cipher, pass, salt)
        key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(pass, salt, 2000,
                                                 cipher.key_len + cipher.iv_len)
        key = key_iv[0, cipher.key_len]
        iv = key_iv[cipher.key_len, cipher.iv_len]
        [key, iv]
      end

      def generate_salt
        SecureRandom.random_bytes(8)
      end

      def secret_password
        ENV.fetch('DB_SECRET')
      end
    end
  end
end
