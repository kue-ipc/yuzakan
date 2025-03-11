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
        return if user_repo.exist_by_name?(username)

        hashed_password = hash_password(password)
        primary_group = userdata.primary_group
          &.then { |name| group_repo.find_by_name(name) }
        member_groups = userdata.groups&.difference([userdata.primary_group])
          &.then { |names| group_repo.all_by_names(names) }

        params = {
          name: username,
          hashed_password: hashed_password,
          display_name: userdata.display_name,
          email: userdata.email,
          attrs: userdata.attrs || {},
          local_group_id: primary_group&.id,
          local_members: member_groups
            &.map { |group| {local_group_id: group.id} } || [],
        }
        user_repo.create_with_members(**params)

        user_read(username)
      end

      def user_read(username)
        user_struct_to_data(user_repo.find_with_groups_by_name(username))
      end

      def user_update(username, **userdata)
        user = user_repo.find_by_name(username)
        return if user.nil?

        primary_group = userdata.primary_group
          &.then { |name| group_repo.find_by_name(name) }
        member_groups = userdata.groups&.difference([userdata.primary_group])
          &.then { |names| group_repo.all_by_names(names) }

        params = {
          display_name: userdata.display_name,
          email: userdata.email,
          **{attrs: userdata.attrs&.merge(user.attrs)}.comact,
          local_group_id: primary_group&.id,
        }
        user_repo.transaction do
          user_repo.update(user.id, **params)
          if member_groups
            remain_group_ids = member_groups.map(&:id)
            user_repo.find_with_members(user.id).local_members.each do |member|
              unless remain_group_ids.delete(member.local_group_id)
                member_repo.delete(member.id)
              end
            end
            remain_group_ids.each do |group_id|
              member_repo.create(local_user_id: user.id,
                local_group_id: group_id)
            end
          end
        end

        user_read(username)
      end

      def user_delete(username)
        user = user_repo.find_with_groups_by_name(username)
        return if user.nil?

        user_repo.delete(user.id)
        user_struct_to_data(user)
      end

      def user_auth(username, password)
        user = user_repo.find_by_name(username)
        return if user.nil?
        return false if user.locked?
        return false if user.hashed_password.nil?

        verify_password(password, user.hashed_password)
      end

      def user_change_password(username, password)
        user = user_repo.find_by_name(username)
        return false if user.nil?

        hashed_password = hash_password(password)
        user_repo.update(user.id, hashed_password:)
        true
      end

      def user_lock(username)
        user = user_repo.find_by_name(username)
        return false if user.nil?
        return false if user.locked?

        user_repo.update(user.id, locked: true)
        true
      end

      def user_unlock(username, _password = nil)
        user = user_repo.find_by_name(username)
        return false if user.nil?
        return false unless user.locked?

        user_repo.update(user.id, locked: false)
        true
      end

      def user_list
        user_repo.names
      end

      def user_search(query)
        user_repo.search_names(query)
      end

      def group_create(groupname, groupdata)
        return if group_repo.exist_by_name?(groupname)

        params = {
          name: groupname,
          display_name: groupdata.display_name,
          attrs: groupdata.attrs || {},
        }
        group_struct_to_data(group_repo.create(**params))
      end

      def group_read(groupname)
        group_struct_to_data(group_repo.find_by_name(groupname))
      end

      def group_update(groupname, groupdata)
        group = group_repo.find_by_name(groupname)
        return if group.nil?

        params = {
          display_name: groupdata.display_name,
          **{attrs: groupdata.attrs&.merge(group.attrs)}.comact,
        }
        group_struct_to_data(group_repo.update(group.id, **params))
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
        group = group_repo.find_with_users_by_name(groupname)
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

      private def hash_password(password)
        return if password.nil?

        @container["operations.hash_password"].call(password).value_or(nil)
      end

      private def verify_password(password, hashed_password)
        @container["operations.verify_password"]
          .call(password, hashed_password).value_or(false)
      end

      private def user_struct_to_data(user)
        return if user.nil?

        UserData.new(
          name: user.name,
          primary_group: user.primary_group&.name,
          groups: user.groups.map(&:name),
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
