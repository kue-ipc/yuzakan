# frozen_string_literal: true

require "bcrypt"

module Local
  module Operations
    class HashPassword < Local::Operation
      def call(password, **)
        password = step validate(password, **)
        step hash(password)
      end

      private def validate(password, allow_empty: false)
        password = password.to_s
        if !allow_empty && password.empty?
          Failure([:invalid, "password is empty"])
        elsif password !~ Yuzakan::Patterns[:password]
          Failure([:invalid, "password contains non-ASCII characters"])
        elsif password.size > 72
          Failure([:invalid, "password is more than 72 characters"])
        else
          Success(password)
        end
      end

      private def hash(password)
        Success(BCrypt::Password.create(password).to_s)
      rescue BCrypt::Error => e
        Failure([:error, e])
      end
    end
  end
end
