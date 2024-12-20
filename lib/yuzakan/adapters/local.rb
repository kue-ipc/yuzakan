# frozen_string_literal: true

module Yuzakan
  module Adapters
    class Local < Yuzakan::Adapter
      self.name = "local"
      self.display_name = "ローカル"
      self.version = "0.0.2"
      self.params = []

      group :primary

      def initialize(params, **opts)
        super
        @user_repo = Hanami.app["repos.local_user_repo"]
        @group_repo = Hanami.app["repos.local_group_repo"]
        @member_repo = Hanami.app["repos.local_member_repo"]

      end

      def check
        true
      end

      def user_create(username, password = nil, **userdata)
        Hanam.app["operations.hash_password"].call(password) =>
          Success[hashed_password]
        user = @repository.create({
          username: username,
          display_name: userdata[:display_name],
          email: userdata[:email],
          hashed_password: hashed_password,
        })
        user_entity_to_data(user)
      end

      def user_read(username)
        user = @repository.find_by_username(username)
        return if user.nil?

        user_entity_to_data(user)
      end

      def user_update(username, **userdata)
        user = @repository.find_by_username(username)
        return if user.nil?

        data = {}
        %i[display_name email].each do |key|
          data[key] = userdata[key] if userdata[key]
        end
        user_entity_to_data(@repository.update(user.id, data))
      end

      def user_delete(username)
        user = @repository.find_by_username(username)
        return if user.nil?

        user_entity_to_data(@repository.delete(user.id))
      end

      def user_auth(username, password)
        user = @repository.find_by_username(username)
        return if user.nil?
        return false if user.locked?

        user.verify_password(password)
      end

      def user_change_password(username, password)
        user = @repository.find_by_username(username)
        return if user.nil?

        Hanam.app["operations.hash_password"].call(password) =>
          Success[hashed_password]
        !!@repository.update(user.id, hashed_password: hashed_password)
      end

      def user_lock(username)
        user = @repository.find_by_username(username)
        return if user.nil?
        return true if user.locked?

        !!@repository.update(user.id, locked: true)
      end

      def user_unlock(username, _password = nil)
        user = @repository.find_by_username(username)
        return if user.nil?
        return true unless user.locked?

        !!@repository.update(user.id, locked: false)
      end

      def user_list
        @repository.all.map(&:username)
      end

      def user_search(query)
        pattern = query.dup
        pattern.gsub!("\\", "\\\\")
        pattern.gsub!("%", '\\%')
        pattern.gsub!("_", '\\_')
        pattern.tr!("*?", "%_")
        @repository.ilike(pattern).map { |data| data[:username] }
      end

      private def user_entity_to_data(user)
        return if user.nil?

        {
          username: user.username,
          display_name: user.display_name,
          email: user.email,
          locked: user.locked?,
          unmanageable: false,
          mfa: false,
          primary_group: nil,
          groups: [],
          attrs: {},
        }
      end
    end
  end
end
