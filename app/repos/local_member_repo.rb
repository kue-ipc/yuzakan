# frozen_string_literal: true

module Yuzakan
  module Repos
    class LocalMemberRepo < Yuzakan::DB::Repo
      commands :create, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}}
      commands :update, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}}
      commands :delete
      private :create, :update, :delete

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
