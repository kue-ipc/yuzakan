# frozen_string_literal: true

module Yuzakan
  module Operations
    class Encrypt < Yuzakan::CryptOperation
      def call(data, bin: false)
        cipher = step create_cipher(:encrypt)
        iv = step generate_iv(cipher)
        salt = step generate_salt
        key = step create_key(cipher, salt)
        encrypted_data = step crypt(data, cipher, iv:, key:)
        joined_data = step join_data(encrypted_data, salt, iv)
        unless bin
          joined_data = step bit2txt(joined_data)
          joined_data = step encode(joined_data, data.encoding)
        end
        joined_data
      end
    end
  end
end
