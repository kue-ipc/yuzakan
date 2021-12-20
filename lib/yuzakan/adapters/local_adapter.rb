require 'bcrypt'

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class LocalAdapter < AbstractAdapter
      def self.label
        'ローカル'
      end

      self.params = []

      def initialize(params)
        super
        @repository = LocalUserRepository.new
      end

      def check
        true
      end

      def create(username, password = nil, **attrs)
        hashed_password = if password
                            BCrypt::Password.create(password)
                          else
                            '!'
                          end
        user = @repository.create(
          name: username,
          display_name: attrs[:display_name] || username,
          email: attrs[:email],
          hashed_password: hashed_password)
        normalize_user(user)
      end

      def read(username)
        user = @repository.by_name(username)
        normalize_user(user)
      end

      def udpate(username, **attrs)
        user = @repository.by_name(username)
        return unless user

        data = {}
        %i[display_name email].each do |key|
          data[key] = attrs[key] if attrs[key]
        end
        updated_user = @repository.update(user.id, data)
        normalize_user(updated_user)
      end

      def delete(username)
        user = @repository.by_name(username)
        return unless user

        @repository.delete(user.id)
      end

      def auth(username, password)
        user = LocalUserRepository.new.by_name(username)

        if user &&
           !user.hashed_password.start_with?('!') &&
           BCrypt::Password.new(user.hashed_password) == password
          return normalize_user(user)
        end

        nil
      end

      def change_password(username, password)
        user = @repository.by_name(username)
        return unless user

        updated_user = @repository.update(
          user.id,
          hashed_password: BCrypt::Password.create(password))
        normalize_user(updated_user)
      end

      def lock(username)
        user = @repository.by_name(username)
        return unless user && !user.hashed_password.start_with?('!')

        @repository.update(
          user.id,
          hashed_password: "!#{user.hashed_password}")
      end

      def unlock(username)
        user = @repository.by_name(username)
        return unless user&.hashed_password&.start_with?('!$')

        @repository.update(
          user.id,
          hashed_password: user.hashed_password[1..])
      end

      def locked?(username)
        user = @repository.by_name(username)
        # 存在しないユーザーは常にロックされているとみなす。
        return true unless user

        user.hashed_password.start_with?('!')
      end

      def list
        @repository.all.map(&:name)
      end

      private def normalize_user(user)
        return unless user

        {
          name: user.name,
          display_name: user.display_name,
          email: user.email,
        }
      end
    end
  end
end
