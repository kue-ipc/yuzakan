# frozen_string_literal: true

module Yuzakan
  module Operations
    class Encrypt < Yuzakan::CryptOperation
      def call(data, bin: false)
        encoding = data.encoding
        cipher = step create_cipher(:encrypt)

        info = {}
        info = step setup_key(cipher, **info)
        info = step setup_iv(cipher, **info)
        info = step setup_auth_data(cipher, **info)

        encrypted_data = step crypt_data(cipher, data)
        info = step setup_auth_tag(cipher, **info)
        joined_data = step join_data(encrypted_data, **info)
        unless bin
          joined_data = step bin2txt(joined_data)
          joined_data = step encode(joined_data, encoding)
        end
        joined_data
      end
    end
  end
end
