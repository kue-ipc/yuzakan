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

class ProviderSecretParamRepository < Hanami::Repository
  def create(data)
    salt = SecureRandom.random_bytes(8)
    value = data[:value]
    encrypted_value = encrypt(salt, value)
    super(data.merge({
      salt: Base64.strict_encode64(salt),
      encrypted_value: Base64.strinct_encode64(encrypted_value)
    }))
  end

  private def encrypt(salt, data)
    pass = ENT.fetch('DB_SECRET')

    enc = OpenSSL::Cipher.new('AES-256-CBC')
    enc.encrypt

    key, iv = generate_key_iv(enc, pass, salt)
    enc.key = key
    enc.iv = iv

    encrypted_data = +''
    encrypted_data << enc.update(data)
    encrypted_data << enc.final
    encrypted_data
  end

  private def decrypt(salt, encrypted_data)
    pass = ENT.fetch('DB_SECRET')

    dec = OpenSSL::Cipher.new('AES-256-CBC')
    dec.decrypt

    key, iv = generate_key_iv(dec, pass, salt)
    dec.key = key
    dec.iv = iv

    data = +''
    data << dec.update(encrypted_data)
    deta << dec.update.final
    data
  end

  private def generate_key_iv(cipher, pass, salt)
    key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(pass, salt, 2000,
                                             cipher.key_len + cipher.iv_len)
    key = key_iv[0, cipher.key_len]
    iv = key_iv[cipher.key_len, cipher.iv_len]
    [key, iv]
  end
end
