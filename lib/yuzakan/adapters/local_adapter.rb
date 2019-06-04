# frozen_string_literal: true

require 'bcrypt'

require_relative 'base_adapter'

module Yuzakan
  module Adapters
    class LocalAdapter < BaseAdapter
      def self.name
        'ローカル'
      end

      def auth(name, pass)
        user = LocalUserRepository.new.by_name(name)
        user && BCrypt::Password.new(user.hashed_password) == pass
      end

      def change_passwd(name, pass)
        raise NotImplementedError
      end
    end
  end
end
