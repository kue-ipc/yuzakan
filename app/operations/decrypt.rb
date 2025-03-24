# frozen_string_literal: true

module Yuzakan
  module Operations
    class Decrypt < Yuzakan::CryptOperation
      def call(encrypted_data, bin: false)
        encrypted_data = step decode64(encrypted_data) unless bin
        step decrypt(encrypted_data)
      end

      def decode64(str)
        Success(Base64.strict_decode64(str))
      rescue => e
        Failuer([:error, e])
      end

      def decrypt(salt_encrypted_data)
        dec = OpenSSL::Cipher.new(crypt_algorithm)
        dec.decrypt
        salt, encrypted_data = split_by_index(salt_encrypted_data, crypt_salt_size)

        key, iv = generate_key_iv(dec, salt)
        dec.key = key
        dec.iv = iv

        data = String.new(encoding: Encoding::ASCII_8BIT)
        data << dec.update(encrypted_data)
        data << dec.final
        Success(data)
      rescue => e
        Failuer([:error, e])
      end
    end
  end
end
