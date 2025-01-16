# frozen_string_literal: true

module Yuzakan
  module Adapters
    class Local < Yuzakan::Adapter
      self.name = "local"
      self.display_name = "ローカル"
      self.version = "0.0.2"
      self.params = []

      group :primary

      def initialize(params, container: ::Local::Slice, **)
        super(params, **)
        @container = container
      end

      def check
        true
      end

      def user_create(username, userdata, password: nil)
        return if user_repo.exist?(username)

        params = {
          name: username,
          display_name: userdata.display_name,
          email: userdata.email,
        }
        if password
          case @container["operations.hash_password"].call(password)
          in Success[hashed_password]
            params[:hashed_password] = hashed_password
          in Failure[:invalid, msg]
            raise AdapterError, msg
          in Failure[:error, err]
            raise err
          end
        end
        user_struct_to_data(user_repo.set(username, **params))
      end

      def user_read(username)
        user_struct_to_data(user_repo.get(username))
      end

      def user_update(username, **userdata)
        return unless user_repo.exist?(username)

        params = {
          display_name: userdata.display_name,
          email: userdata.email,
        }
        user_struct_to_data(user_repo.set(username, **params))
      end

      def user_delete(username)
        user_struct_to_data(user_repo.unset(username))
      end

      def user_auth(username, password)
        user = user_repo.get(username)
        return if user.nil?
        return false if user.locked?
        return false if user.hashed_password.nil?

        case @container["operations.verify_password"]
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
        return unless user_repo.exist?(username)

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
        !!user_repo.set(username, hashed_password:)
      end

      def user_generate_code(username)
      end

      def user_reset_mfa(username)
      end

      def user_lock(username)
        user = user_repo.get(username)
        return if user.nil?
        return true if user.locked?

        !!user_repo.set(username, locked: true)
      end

      def user_unlock(username, _password = nil)
        user = user_repo.get(username)
        return if user.nil?
        return true unless user.locked?

        !!user_repo.set(username, locked: false)
      end

      def user_list
        user_repo.list
      end

      def user_search(query)
        user_repo.search(query)
      end

      def user_group_list(username)
        user = user_repo.get(username)
        group_repo.list_of_user(user)
      end

      def group_create(groupname, groupdata)
        return if group_repo.exist_by_name?(groupname)

        params = {
          name: groupname,
          display_name: groupdata.display_name,
          attrs: groupdata.attrs,
        }
        group_struct_to_data(group_repo.create(**params))
      end

      def group_read(groupname)
        group_struct_to_data(group_repo.find_by_name(groupname))
      end

      def group_update(groupname, groupdata)
        return unless group_repo.exist?(groupname)

        params = {
          display_name: groupdata.display_name,
          attrs: groupdata.attrs,
        }.compact
        group_struct_to_data(
          group_repo.update_by_name(groupname, **params))
      end

      def group_delete(groupname)
        group_struct_to_data(group_repo.delete_by_name(groupname))
      end

      def group_list
        group_repo.names
      end

      def group_search(query)
        group_repo.search_names(query)
      end

      def member_list(groupname)
        group = group_repo
          .find_with_users_by_name(groupname)
        return if group.nil?

        group.members.map(:name)
      end

      def member_add(groupname, username)
        group = group_repo.find_by_name(groupname)
        return false if group.nil?

        user = user_repo.find_by_name(username)
        return false if user.nil?
        return false if user.lcoal_group_id == group.id

        member = member_repo.find_by_local_user_by_local_group(user, group)
        return false if member

        member_repo.create(local_user_id: user.id, local_group_id: group.id)
        true
      end

      def member_remove(groupname, username)
        group = group_repo.find_by_name(groupname)
        return false if group.nil?

        user = user_repo.find_by_name(username)
        return false if user.nil?

        change = false

        if user.lcoal_group_id == group.id
          user_repo.update(user.id, local_group_id: nil)
          change = true
        end

        member = member_repo.find_by_local_user_by_local_group(user, group)
        if member
          member_repo.delete(member.id)
          change = true
        end
        change
      end

      # private methods
      private def user_repo = @container["repos.local_user_repo"]
      private def group_repo = @container["repos.local_group_repo"]
      private def member_repo = @container["repos.local_member_repo"]

      private def user_struct_to_data(user)
        return if user.nil?

        UserData.new(
          name: user.name,
          primary_group: user.primary_group&.name,
          groups: user.groups.map(:name),
          display_name: user.display_name,
          email: user.email,
          locked: user.locked?)
      end

      private def group_struct_to_data(group)
        return if group.nil?

        GroupData.new(
          name: group.name,
          display_name: group.display_name)
      end
    end
  end
end
