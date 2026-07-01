# frozen_string_literal: true

module Yuzakan
  module Repos
    class ManagedUserRepo < Yuzakan::DB::Repo
      # for associations
      private def for_user(user) = managed_users.by_user_id(user.id)
      private def for_service(service) = managed_users.by_service_id(service.id)

      private def for_user_and_service(user, service)
        managed_users.by_user_id_and_by_service_id(user.id, service.id)
      end

      def all_for_user(user) = for_user(user).to_a
      def all_for_service(service) = for_service(service).to_a
      def clear_for_user(user) = for_user(user).command(:delete).call
      def clear_for_service(service) = for_service(service).command(:delete).call

      def create_for_user_and_service(user, service) = create(user_id: user.id, service_id: service.id)
      def delete_for_user_and_service(user, service) = for_user_and_service(user, service).command(:delete).call
      def find_for_user_and_service(user, service) = for_user_and_service(user, service).one
      def exist_for_user_and_service?(user, service) = for_user_and_service(user, service).exist?

      def set_services_for_user(user, services)
        service_ids = services.map(&:first).map(&:id)
        managed_users.transaction do
          for_user(user).exclude(service_id: service_ids).command(:delete).call
          current_service_ids = for_user(user).pluck(:service_id)
          services.reject { |service| current_service_ids.include?(service.id) }.each do |service|
            create_for_user_and_service(user, service)
          end
        end
      end
    end
  end
end
