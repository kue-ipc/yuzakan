require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class LocalAdapter < AbstractAdapter
      self.name = 'local'
      self.label = 'ローカル'
      self.version = '0.0.1'
      self.params = []

      def initialize(params, **opts)
        super
        @repository = LocalUserRepository.new
      end

      def check
        true
      end

      def create(username, password = nil, **userdata)
        hashed_password = LocalUser.create_hashed_password(password)
        user = @repository.create({
          name: username,
          display_name: userdata[:display_name] || username,
          email: userdata[:email],
          hashed_password: hashed_password,
        })
        user2userdata(user)
      end

      def read(username)
        user2userdata(@repository.find_by_name(username))
      end

      def udpate(username, **userdata)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?

        data = {}
        %i[display_name email].each do |key|
          data[key] = userdata[key] if userdata[key]
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
        user &&
          !user.hashed_password.start_with?('!') &&
          user.verify_password(password)
      end

      def change_password(username, password)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?

        hashed_password = LocalUser.create_hashed_password(password)
        hashed_password = LocalUser.lock_password(hashed_password) if user.locked?

        @repository.update(user.id, hashed_password: hashed_password)
      end

      def lock(username)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?
        return if user.locked?

        @repository.update(user.id, hashed_password: LocalUser.lock_password(user.hashed_password))
      end

      def unlock(username, _password = nil)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?
        return unless user.locked?

        @repository.update(user.id, hashed_password: LocalUser.unlock(user.hashed_password))
      end

      def locked?(username)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?

        user.locked?
      end

      def list
        @repository.all.map(&:name)
      end

      def search(query)
        pattern = query.dup
        pattern.gsub!('\\', '\\\\')
        pattern.gsub!('%', '\\%')
        pattern.gsub!('_', '\\_')
        pattern.tr!('*?', '%_')
        @repository.ilike(pattern).map { |data| data[:name] }
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
