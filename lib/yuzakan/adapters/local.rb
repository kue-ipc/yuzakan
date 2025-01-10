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
        @local_user_repo = Hanami.app["repos.local_user_repo"]
        @local_group_repo = Hanami.app["repos.local_group_repo"]
        @local_member_repo = Hanami.app["repos.local_member_repo"]
      end

      def check
        true
      end

      def user_create(username, password = nil, **userdata)
        return if @local_user_repo.exist?(useranme)

        params = {
          name: username,
          display_name: userdata[:display_name],
          email: userdata[:email],
        }
        if password
          case Hanam.app["operations.hash_password"].call(password)
          in Success[hashed_password]
            params[:hashed_password] = hashed_password
          in Failure[:invalid, msg]
            raise AdapterError, msg
          in Failure[:error, err]
            raise err
          end
        end
        user_struct_to_data(@local_user_repo.set(username, **params))
      end

      def user_read(username)
        user_struct_to_data(@local_user_repo.get(username))
      end

      def user_update(username, **userdata)
        return unless @local_user_repo.exist?(username)

        params = userdata.slice(:display_name, :email)
        user_struct_to_data(@local_user_repo.set(username, **params))
      end

      def user_delete(username)
        user_struct_to_data(@local_user_repo.unset(username))
      end

      def user_auth(username, password)
        user = @local_user_repo.get(username)
        return if user.nil?
        return false if user.locked?
        return false if user.hashed_password.nil?

        case Hanam.app["operations.verify_password"]
          .call(password, user.hashed_password)
        in Success[result]
          result
        in Failure[:invalid, msg]
          raise AdapterError, msg
        in Failure[:error, err]
          raise err
        end
      end

      def user_change_password(username, password)
        return unless @local_user_repo.exist?(username)

        hashed_password =
          if password
            case Hanam.app["operations.hash_password"].call(password)
            in Success[hashed_password]
              hashed_password
            in Failure[:invalid, msg]
              raise AdapterError, msg
            in Failure[:error, err]
              raise err
            end
          end
        !!@local_user_repo.set(username, hashed_password:)
      end

      def user_generate_code(username)
      end

      def user_reset_mfa(username)
      end

      def user_lock(username)
        user = @local_user_repo.get(username)
        return if user.nil?
        return true if user.locked?

        !!@local_user_repo.set(username, locked: true)
      end

      def user_unlock(username, _password = nil)
        user = @local_user_repo.get(username)
        return if user.nil?
        return true unless user.locked?

        !!@local_user_repo.set(username, locked: false)
      end

      def user_list
        @local_user_repo.list
      end

      def user_search(query)
        @local_user_repo.search(query)
      end

      def user_group_list(username)
        user = @local_user_repo.get(username)
        @local_group_repo.list_of_user(user)
      end

      def group_create(groupname, **groupdata)
        return if @local_group_repo.exist?(groupanme)

        params = {
          name: groupname,
          display_name: groupdata[:display_name],
        }
        group_struct_to_data(@local_group_repo.set(groupname, **params))
      end

      def group_list
        raise NoMethodError, "Not implement #{self.class}##{__method__}"
      end

      def group_search(query)
        raise NoMethodError, "Not implement #{self.class}##{__method__}"
      end

      def member_list(groupname)
        raise NoMethodError, "Not implement #{self.class}##{__method__}"
      end

      def member_add(groupname, username)
        raise NoMethodError, "Not implement #{self.class}##{__method__}"
      end

      def member_remove(groupname, username)
        raise NoMethodError, "Not implement #{self.class}##{__method__}"
      end

      # private methods

      private def user_struct_to_data(user)
        return if user.nil?

        {
          username: user.name,
          display_name: user.display_name,
          email: user.email,
          locked: user.locked?,
          unmanageable: false,
          mfa: false,
          primary_group: user.primary_group.map(:name),
          groups: user.groups.map(:name),
          attrs: {},
        }
      end

      private def group_struct_to_data(group)
        return if group.nil?

        {
          groupname: group.name,
          display_name: group.display_name,
          unmanageable: false,
          attrs: {},
        }
      end
    end
  end
end
