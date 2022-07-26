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

      def user_create(username, password = nil, **userdata)
        hashed_password = LocalUser.create_hashed_password(password)
        user = @repository.create({
          name: username,
          display_name: userdata[:attrs]['display_name'],
          email: userdata[:attrs]['email'],
          hashed_password: hashed_password,
        })
        user_entity_to_data(user)
      end

      def user_read(username)
        user_entity_to_data(@repository.find_by_name(username))
      end

      def user_update(username, **userdata)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?

        data = {}
        %i[display_name email].each do |key|
          data[key] = userdata[key] if userdata[key]
        end
        user_entity_to_data(@repository.update(user.id, data))
      end

      def user_delete(username)
        user = @repository.find_by_name(username)
        raise "user not found: #{username}" if user.nil?

        @repository.delete(user.id)
      end

      def user_auth(username, password)
        user = @repository.find_by_name(username)
        user &&
          !user.hashed_password.start_with?('!') &&
          user.verify_password(password)
      end

      def user_change_password(username, password)
        user = @repository.find_by_name(username)
        return false if user.nil?

        hashed_password = LocalUser.create_hashed_password(password)
        hashed_password = LocalUser.lock_password(hashed_password) if user.locked?

        @repository.update(user.id, hashed_password: hashed_password)
      end

      def user_lock(username)
        user = @repository.find_by_name(username)
        return if user.nil?
        return if user.locked?

        @repository.update(user.id, hashed_password: LocalUser.lock_password(user.hashed_password))
      end

      def user_unlock(username, _password = nil)
        user = @repository.find_by_name(username)
        return if user.nil?
        return unless user.locked?

        @repository.update(user.id, hashed_password: LocalUser.unlock(user.hashed_password))
      end

      def user_list
        @repository.all.map(&:name)
      end

      def user_search(query)
        pattern = query.dup
        pattern.gsub!('\\', '\\\\')
        pattern.gsub!('%', '\\%')
        pattern.gsub!('_', '\\_')
        pattern.tr!('*?', '%_')
        @repository.ilike(pattern).map { |data| data[:name] }
      end

      private def user_entity_to_data(user)
        return if user.nil?

        {
          name: user.name,
          display_name: user.display_name,
          email: user.email,
          locked: user.locked?,
          disabled: user.disabled?,
          attrs: {
            'name' => user.name,
            'display_name' => user.display_name,
            'email' => user.email,
          }
        }
      end
    end
  end
end
