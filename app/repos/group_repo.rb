# frozen_string_literal: true

module Yuzakan
  module Repos
    class GroupRepo < Yuzakan::DB::Repo
      private def with_all(relation) = relation.combine(:affiliation, :users, members: :users, managings: :service)
      private def with_associations(relation) = relation.combine(:affiliation, :services)

      # def get_with_affiliation(name)
      #   by_name(name).combine(:affiliation).one
      # end

      # TODO: ここらは下は未整理

      # def ordered_all
      #   groups.order(:name).to_a
      # end

      # def ordered_filter(order: {name: :asc}, filter: {})
      # end

      # # def filter(query: nil, match: :partial, basic: nil, prohibited: nil,
      # #   deleted: nil)
      # # end

      # # def search(query: nil, match: :partial)
      # # end

      # def all_by_name(name)
      #   by_name(name).to_a
      # end

      # def find_by_name(name)
      #   by_name(name).one
      # end

      # def find_or_create_by_name(name)
      #   find_by_name(name) || create({name: name})
      # end

      # def add_user(group, user)
      #   member = member_for(group, user)
      #   return if member

      #   assoc(:members, group).add(user_id: user.id)
      # end

      # def remove_user(group, user)
      #   member = member_for(group, user)
      #   return unless member

      #   assoc(:members, group).remove(member.id)
      # end

      # private def member_for(group, user)
      #   assoc(:members, group).where(user_id: user.id).to_a.first
      # end

      # def clear_user(group)
      #   assoc(:members, group).delete
      # end
    end
  end
end
