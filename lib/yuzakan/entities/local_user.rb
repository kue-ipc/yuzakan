require 'bcrypt'

class LocalUser < Hanami::Entity
  class << self
    def create_hashed_password(password)
      return '*' if password.nil?

      BCrypt::Password.create(password)
    end

    def lock_password(password)
      "!!#{password}"
    end

    def unlock_password(password)
      password[2..]
    end
  end

  def name
    Hanami.logger.warn('call LocalUser#name')
    username
  end

  def verify_password(password)
    bcrypt_password == password
  end

  def bcrypt_password
    BCrypt::Password.new(hashed_password)
  end

  def locked?
    hashed_password.start_with?('!!')
  end

  def disabled?
    hashed_password.start_with?('*', '!!*')
  end
end
