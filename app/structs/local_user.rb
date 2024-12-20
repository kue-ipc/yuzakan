# frozen_string_literal: true

require "bcrypt"

module Yuzakan
  module Structs
    class LocalUser < Yuzakan::DB::Struct
      def name
        Hanami.logger.warn("call LocalUser#name")
        username
      end

      def verify_password(password)
        bcrypt_password == password
      end

      def bcrypt_password
        BCrypt::Password.new(hashed_password)
      end

      def locked?
        locked
      end
    end
  end
end
