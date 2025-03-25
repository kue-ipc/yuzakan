# frozen_string_literal: true

module Yuzakan
  module Operations
    class Decrypt < Yuzakan::CryptOperation
      def call(data, bin: false)
        encoding = data.encoding
        cipher = step create_cipher(:decrypt)
        data = step txt2bin(data) unless bin
        encrypted_data, salt, iv = step split_data(data, cipher)
        key = step create_key(cipher, salt)
        decrypted_data = step crypt(encrypted_data, cipher, iv:, key:)
        decrypted_data = step encode(decrypted_data, encoding) unless bin
        decrypted_data
      end
    end
  end
end
