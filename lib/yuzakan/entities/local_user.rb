# frozen_string_literal: true

require 'bcrypt'

class LocalUser < Hanami::Entity
  class << self
    def create_hashed_password(password)
      return nil if password.nil?

      BCrypt::Password.create(password)
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
    locked
  end
end
