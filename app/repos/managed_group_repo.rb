# frozen_string_literal: true

module Yuzakan
  module Repos
    class ManagedGroupRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = managed_groups.to_a
      def find(id) = managed_groups.by_pk(id).one
      def first = managed_groups.first
      def last = managed_groups.last
      def clear = managed_groups.delete

      # other interfaces
      private def by_group(group) = managed_groups.by_group_id(group.id)
      private def by_service(service) = managed_groups.by_service_id(service.id)
      private def by_group_and_service(group, service)
        managed_groups.by_group_id(group.id).by_service_id(service.id)
      end

      def delete_by_group(group) = by_group(group).command(:delete).call
      def delete_by_service(service) = by_service(service).command(:delete).call

      def create_by_group_and_service(group, service) = create(group_id: group.id, service_id: service.id)
      def delete_by_group_and_service(group, service) = by_group_and_service(group, service).command(:delete).call
      def find_by_group_and_service(group, service) = by_group_and_service(group, service).one
      def exist_by_group_and_service?(group, service) = by_group_and_service(group, service).exist?
    end
  end
end
