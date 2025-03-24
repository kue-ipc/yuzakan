# frozen_string_literal: true

module Yuzakan
  module Operations
    class Encrypt < Yuzakan::CryptOperation
      def call(decrypted_data, bin: false)
        encrypted_data = step encrypt(decrypted_data)
        unless bin
          encrypted_data =
            step encode64(encrypted_data, encoding: decrypted_data.encoding)
        end
        encrypted_data
      end

      def encrypt(decrypted_data)
        salt = generate_salt

        enc = OpenSSL::Cipher.new(crypt_algorithm)
        enc.encrypt

        key, iv = generate_key_iv(enc, salt)
        enc.key = key
        enc.iv = iv

        encrypted_data = String.new(encoding: Encoding::ASCII_8BIT)
        encrypted_data << enc.update(decrypted_data)
        encrypted_data << enc.final
        Success(salt + encrypted_data)
      end

      def encode64(data, encoding: Encoding::UTF_8)
        Success(Base64.strict_encode64(data).encode(encoding))
      rescue => e
        Failuer([:error, e])
      end
    end
  end
end
