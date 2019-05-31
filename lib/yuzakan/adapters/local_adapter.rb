# frozen_string_literal: true

require 'bcrypt'

# LocalAdapter
#
# CRUD
# create(name, attrs)
# read(name) -> attrs
# update(name, attrs)
# delete(name)
#
# search(name)
# chaneg_passwd(user, pass)
# auth(name, pass)
#

module Yuzakan
  module Adapters
    class LocalAdapter
      def self.name
        'ローカル'
      end

      def self.params
        []
      end

      def initialize(params)
        @params = params
      end

      def create(name, attrs)
        raise NotImplementedError
      end

      def read(name)
        raise NotImplementedError
      end

      def udpate(name, attrs)
        raise NotImplementedError
      end

      def delete(name)
        raise NotImplementedError
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
