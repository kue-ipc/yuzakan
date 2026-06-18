# frozen_string_literal: true

module Yuzakan
  module Repos
    class ManagedGroupRepo < Yuzakan::DB::Repo
      # for associations
      private def for_group(group) = managed_groups.by_group_id(group.id)
      private def for_service(service) = managed_groups.by_service_id(service.id)

      private def for_group_and_service(group, service)
        managed_groups.by_group_id_and_by_service_id(group.id, service.id)
      end

      def all_for_group(group) = for_group(group).to_a
      def all_for_service(service) = for_service(service).to_a
      def clear_for_group(group) = for_group(group).command(:delete).call
      def clear_for_service(service) = for_service(service).command(:delete).call

      def create_for_group_and_service(group, service, **) = create(group_id: group.id, service_id: service.id, **)

      def update_for_group_and_service(group, service, **)
        for_group_and_service(group, service).command(:update, **UPDATE_TIMESTAMP).call(**)
      end

      def delete_for_group_and_service(group, service) = for_group_and_service(group, service).command(:delete).call
      def find_for_group_and_service(group, service) = for_group_and_service(group, service).one
      def exist_for_group_and_service?(group, service) = for_group_and_service(group, service).exist?

      def set_services_for_group(group, services)
        service_ids = services.map(&:first).map(&:id)
        managed_groups.transaction do
          for_group(group).exclude(service_id: service_ids).command(:delete).call
          current_service_ids = for_group(group).pluck(:service_id)
          services.each do |service, params|
            if current_service_ids.include?(service.id)
              update_for_group_and_service(group, service, **params)
            else
              create_for_group_and_service(group, service, **params)
            end
          end
        end
      end
    end
  end
end
