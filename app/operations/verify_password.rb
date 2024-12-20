# frozen_string_literal: true

module Yuzakan
  module Operations
    class VerifyPassword < Yuzakan::Operation
      def call(password, hashed_password, **)
        password, hashed_password = step validate(password, hashed_password, **)
        step verify(password, hashed_password)
      end

      #TODO: 書いている最中
      private def validate(password, hashed_password, **all)


        if BCrypt::Password.vaild_hash?(hashed_password)

        end
      end

      private def create_bcrypt(hashed_password)
        if hashed_password.nil?
          Failure(:nil)
        end

        Success(BCrypt::Password.new(hashed_password))
      rescue BCrypt::Errors::InvalidHash

      end

      def verify(password, bcrypt_password)
        BCrypt::Password.new(hashed_password)
        bcrypt_password == password

      end
    end
  end
end
