# frozen_string_literal: true

module Yuzakan
  module Adapters
    class Local < Yuzakan::Adapter
      version "0.1.0"
      group true
      primary_group true

      json {} # rubocop:disable Lint/EmptyBlock

      def initialize(params, container: ::Local::Slice, **)
        super(params, **)
        @container = container
      end

      def check
        true
      end

      def user_create(username, userdata, password: nil)
        return if local_user_repo.exist_by_name?(username)

        hashed_password = hash_password(password)
        local_group = userdata.primary_group
          &.then { |name| local_group_repo.find_by_name(name) }
        local_members = userdata.groups&.difference([userdata.primary_group])
          &.then { |names| local_group_repo.all_by_names(names) }

        params = {
          name: username,
          hashed_password: hashed_password,
          label: userdata.label || "",
          email: userdata.email || "",
          attrs: userdata.attrs || {},
          local_group_id: local_group&.id,
          local_members: local_members
            &.map { |local_member| {local_group_id: local_member.id} } || [],
        }
        local_user_repo.create_with_members(**params)

        user_read(username)
      end

      def user_read(username)
        user_struct_to_data(local_user_repo.find_with_groups_by_name(username))
      end

      def user_update(username, **userdata)
        local_user = local_user_repo.find_by_name(username)
        return if local_user.nil?

        primary_group = userdata.primary_group
          &.then { |name| local_group_repo.find_by_name(name) }
        member_groups = userdata.groups&.difference([userdata.primary_group])
          &.then { |names| local_group_repo.all_by_names(names) }

        params = {
          label: userdata.label,
          email: userdata.email,
          **{attrs: userdata.attrs&.merge(local_user.attrs)}.comact,
          local_group_id: primary_group&.id,
        }
        local_user_repo.transaction do
          local_user_repo.update(local_user.id, **params)
          if member_groups
            remain_group_ids = member_groups.map(&:id)
            local_user_repo.find_with_members(local_user.id).local_members.each do |local_member|
              local_member_repo.delete(local_member.id) unless remain_group_ids.delete(local_member.local_group_id)
            end
            remain_group_ids.each do |group_id|
              local_member_repo.create(local_user_id: local_user.id,
                local_group_id: group_id)
            end
          end
        end

        user_read(username)
      end

      def user_delete(username)
        local_user = local_user_repo.find_with_groups_by_name(username)
        return if local_user.nil?

        local_user_repo.delete(local_user.id)
        user_struct_to_data(local_user)
      end

      def user_auth(username, password)
        local_user = local_user_repo.find_by_name(username)
        return if local_user.nil?
        return false if local_user.locked
        return false if local_user.hashed_password.empty?

        verify_password(password, local_user.hashed_password)
      end

      def user_change_password(username, password)
        local_user = local_user_repo.find_by_name(username)
        return false if local_user.nil?

        hashed_password = hash_password(password)
        local_user_repo.update(local_user.id, hashed_password:)
        true
      end

      def user_lock(username)
        local_user = local_user_repo.find_by_name(username)
        return false if local_user.nil?
        return false if local_user.locked

        local_user_repo.update(local_user.id, locked: true)
        true
      end

      def user_unlock(username, _password = nil)
        local_user = local_user_repo.find_by_name(username)
        return false if local_user.nil?
        return false unless local_user.locked

        local_user_repo.update(local_user.id, locked: false)
        true
      end

      def user_list
        local_user_repo.names
      end

      def user_search(query)
        local_user_repo.search_names(query)
      end

      def group_create(groupname, groupdata)
        return if local_group_repo.exist_by_name?(groupname)

        params = {
          name: groupname,
          label: groupdata.label,
          attrs: groupdata.attrs || {},
        }
        group_struct_to_data(local_group_repo.create(**params))
      end

      def group_read(groupname)
        group_struct_to_data(local_group_repo.find_by_name(groupname))
      end

      def group_update(groupname, groupdata)
        local_group = local_group_repo.find_by_name(groupname)
        return if local_group.nil?

        params = {
          label: groupdata.label,
          **{attrs: groupdata.attrs&.merge(local_group.attrs)}.comact,
        }
        group_struct_to_data(local_group_repo.update(local_group.id, **params))
      end

      def group_delete(groupname)
        group_struct_to_data(local_group_repo.delete_by_name(groupname))
      end

      def group_list
        local_group_repo.names
      end

      def group_search(query)
        local_group_repo.search_names(query)
      end

      def member_list(groupname)
        local_group = local_group_repo.find_with_users_by_name(groupname)
        return if local_group.nil?

        [local_group.lcoal_users + local_group.local_member_users].map(:name)
      end

      def member_add(groupname, username)
        local_group = local_group_repo.find_by_name(groupname)
        return false if local_group.nil?

        local_user = local_user_repo.find_by_name(username)
        return false if local_user.nil?
        return false if local_user.lcoal_group_id == local_group.id

        local_member = local_member_repo.find_by_local_user_by_local_group(local_user, local_group)
        return false if local_member

        local_member_repo.create(local_user_id: local_user.id, local_group_id: local_group.id)
        true
      end

      def member_remove(groupname, username)
        local_group = local_group_repo.find_by_name(groupname)
        return false if local_group.nil?

        local_user = local_user_repo.find_by_name(username)
        return false if local_user.nil?

        change = false

        if local_user.lcoal_group_id == local_group.id
          local_user_repo.update(local_user.id, local_group_id: nil)
          change = true
        end

        local_member = local_member_repo.find_by_local_user_by_local_group(local_user, local_group)
        if local_member
          local_member_repo.delete(local_member.id)
          change = true
        end
        change
      end

      # private methods
      private def local_user_repo = @container["repos.local_user_repo"]
      private def local_group_repo = @container["repos.local_group_repo"]
      private def local_member_repo = @container["repos.local_member_repo"]

      private def hash_password(password)
        return if password.nil?

        @container["operations.hash_password"].call(password).value_or(nil)
      end

      private def verify_password(password, hashed_password)
        @container["operations.verify_password"]
          .call(password, hashed_password).value_or(false)
      end

      private def user_struct_to_data(local_user)
        return if local_user.nil?

        UserData.new(
          name: local_user.name,
          primary_group: local_user.local_group&.name,
          groups: local_user.local_member_groups.map(&:name),
          label: local_user.label,
          email: local_user.email,
          locked: local_user.locked)
      end

      private def group_struct_to_data(local_group)
        return if local_group.nil?

        GroupData.new(
          name: local_group.name,
          label: local_group.label)
      end
    end
  end
end
