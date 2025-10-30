# frozen_string_literal: true

require "bcrypt"

module Local
  module Operations
    class VerifyPassword < Local::Operation
      def call(password, hashed_password, **)
        password, hashed_password = step validate(password, hashed_password, **)
        bcrypt_password = step create_bcrypt(hashed_password)
        step verify(password, bcrypt_password)
      end

      private def validate(password, hashed_password, allow_empty: false)
        password = password.to_s
        hashed_password = hashed_password.to_s
        if !allow_empty && password.empty?
          Failure([:invalid, "password is empty"])
        elsif password !~ Yuzakan::Patterns[:password]
          Failure([:invalid, "password contains non-ASCII characters"])
        elsif password.size > 72
          Failure([:invalid, "password is more than 72 characters"])
        elsif !BCrypt::Password.valid_hash?(hashed_password)
          Failure([:invalid, "invalid hashed password"])
        else
          Success([password, hashed_password])
        end
      end

      private def create_bcrypt(hashed_password)
        Success(BCrypt::Password.new(hashed_password))
      rescue BCrypt::Errors::InvalidHash
        Failure([:invalid, "invalid hashed password"])
      end

      private def verify(password, bcrypt_password)
        Success(bcrypt_password == password)
      end
    end
  end
end
