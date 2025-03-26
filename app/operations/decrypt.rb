# frozen_string_literal: true

module Yuzakan
  module Operations
    class Decrypt < Yuzakan::CryptOperation
      def call(data, bin: false)
        encoding = data.encoding
        cipher = step create_cipher(:decrypt)

        data = step txt2bin(data) unless bin
        encrypted_data, info = step split_data(data, cipher)

        step setup_key(cipher, **info)
        step setup_iv(cipher, **info)
        step setup_auth_data(cipher, **info)
        step setup_auth_tag(cipher, **info)

        decrypted_data = step crypt_data(cipher, encrypted_data)
        decrypted_data = step encode(decrypted_data, encoding) unless bin
        decrypted_data
      end
    end
  end
end
