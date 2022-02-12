require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class LocalAdapter < AbstractAdapter
      self.label = 'Local'

      self.params = []

      def initialize(params)
        super
        @repository = LocalUserRepository.new
      end

      def check
        true
      end

      def create(username, password = nil, **userdata)
        user2userdata(@repository.create_with_password(
                        name: username,
                        display_name: userdata[:display_name] || username,
                        email: userdata[:email],
                        password: password))
      end

      def read(username)
        user2userdata(@repository.find_by_name(username))
      end

      def udpate(username, **_userdata)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?

        data = {}
        %i[display_name email].each do |key|
          data[key] = attrs[key] if attrs[key]
        end
        user2userdata(@repository.update(user.id, data))
      end

      def delete(username)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?

        @repository.delete(user.id)
      end

      def auth(username, password)
        user = @repository.find_by_name(username)
        return false if user.nil?
        return false if user.hashed_password.start_with?('!')

        user.verify_password(password)
      end

      def change_password(username, password)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?

        @repository.change_password(user.id, password: password)
      end

      def lock(username)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?

        @repository.lock(user.id)
      end

      def unlock(username, _password = nil)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?

        @repository.unlock(user.id)
      end

      def locked?(username)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?

        user.locked?
      end

      def list
        @repository.all.map(&:name)
      end

      private def user2userdata(user)
        return if user.nil?

        {
          name: user.name,
          display_name: user.display_name,
          email: user.email,
          locked: user.locked?,
          disabled: user.disabled?,
        }
      end
    end
  end
end
