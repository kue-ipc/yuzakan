# frozen_string_literal: true

module Yuzakan
  module Repos
    class ManagedUserRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = managed_users.to_a
      def find(id) = managed_users.by_pk(id).one
      def first = managed_users.first
      def last = managed_users.last
      def clear = managed_users.delete

      # other interfaces
      private def by_user(user) = managed_users.by_user_id(user.id)
      private def by_service(service) = managed_users.by_service_id(service.id)
      private def by_user_and_service(user, service)
        managed_users.by_user_id(user.id).by_service_id(service.id)
      end

      def delete_by_user(user) = by_user(user).command(:delete).call
      def delete_by_service(service) = by_service(service).command(:delete).call

      def create_by_user_and_service(user, service) = create(user_id: user.id, service_id: service.id)
      def delete_by_user_and_service(user, service) = by_user_and_service(user, service).command(:delete).call
      def find_by_user_and_service(user, service) = by_user_and_service(user, service).one
      def exist_by_user_and_service?(user, service) = by_user_and_service(user, service).exist?
    end
  end
end
