# frozen_string_literal: true

module Local
  module Repos
    class LocalMemberRepo < Local::DB::Repo
      commands :create, :update, :delete

      def of_group(local_group)
      end

      def add_member(local_group, local_user)
        local_members
          .by_local_user_id_and_local_group_id(local_user.id, local_group.id)
          .one ||
          create(local_user_id: local_user.id, local_group_id: local_group.id)
      end
    end
  end
end
