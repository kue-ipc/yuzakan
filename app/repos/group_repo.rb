# frozen_string_literal: true

module Yuzakan
  module Repos
    class GroupRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = groups.to_a
      def find(id) = groups.by_pk(id).one
      def first = groups.first
      def last = groups.last
      def clear = groups.delete

      # common interfaces
      private def by_name(name) = groups.by_name(name)
      def get(name) = by_name(name).one
      def set(name, **) = by_name(name).command(:update, **UPDATE_TIMESTAMP).call(**) || create(name: name, **)
      def unset(name) = by_name(name).command(:delete).call
      def exist?(name) = by_name(name).exist?
      def list = groups.pluck(:name)

      # index = filter & search & order & paginate
      def index(page: nil, per_page: nil, order: nil, query: nil, filter: nil)
        relations = groups

        relations = filter(relations, filter:)
        relations = search(relations, targets: [:name, :label], query:)
        relations = order(relations, order:)
        relations = paginate(relations, page:, per_page:)
        [relations.to_a, relations.pager]
      end

      # other interfaces
      def get_with_affiliation(name)
        by_name(name).combine(:affiliation).one
      end

      # TODO: ここらは下は未整理

      def ordered_all
        groups.order(:name).to_a
      end

      def ordered_filter(order: {name: :asc}, filter: {})
      end

      # def filter(query: nil, match: :partial, basic: nil, prohibited: nil,
      #   deleted: nil)
      # end

      # def search(query: nil, match: :partial)
      # end

      def all_by_name(name)
        by_name(name).to_a
      end

      def find_by_name(name)
        by_name(name).one
      end

      def find_or_create_by_name(name)
        find_by_name(name) || create({name: name})
      end

      def add_user(group, user)
        member = member_for(group, user)
        return if member

        assoc(:members, group).add(user_id: user.id)
      end

      def remove_user(group, user)
        member = member_for(group, user)
        return unless member

        assoc(:members, group).remove(member.id)
      end

      private def member_for(group, user)
        assoc(:members, group).where(user_id: user.id).to_a.first
      end

      def clear_user(group)
        assoc(:members, group).delete
      end
    end
  end
end
