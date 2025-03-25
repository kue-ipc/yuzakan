# frozen_string_literal: true

module Yuzakan
  module Operations
    class Decrypt < Yuzakan::CryptOperation
      def call(data, bin: false)
        cipher = step create_cipher(:decrypt)
        data = step txt2bin(data) unless bin
        encrypted_data, salt, iv = split_salt(data)
        key = step create_key_iv(cipher, salt)
        decrypted_data = step crypt(encrypted_data, cipher, iv:, key:)
        decrypted_data = step encode(decrypted_data, data.encoding) unless bin
        decrypted_data
      end
    end
  end
end
