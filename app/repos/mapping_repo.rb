# frozen_string_literal: true

module Yuzakan
  module Repos
    class MappingRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = mappings.to_a
      def find(id) = mappings.by_pk(id).one
      def first = mappings.first
      def last = mappings.last
      def clear = mappings.delete

      # other interfaces
      def all_with_attrs_by_service(service)
        mappings.by_service_id(service.id).combine(:attrs).to_a
      end

      private def by_attr_id(attr_id) = mappings.by_attr_id(attr_id)
      private def by_service_id(service_id) = mappings.by_service_id(service_id)
      private def by_attr_id_and_service_id(attr_id, service_id) = by_attr_id(attr_id).by_service_id(service_id)
      def all_by_attr_id(attr_id) = by_attr_id(attr_id).to_a
      def all_by_service_id(service_id) = by_service_id(service_id).to_a
      def find_by_attr_id_and_service_id(attr_id, service_id) = by_attr_id_and_service_id(attr_id, service_id).one

      def update_by_attr_id_and_service_id(attr_id, service_id, **)
        by_attr_id_and_service_id(attr_id, service_id)
          .command(:update, **UPDATE_TIMESTAMP)
          .call(**)
      end

      def delete_by_attr_id_and_service_id(attr_id, service_id)
        by_attr_id_and_service_id(attr_id, service_id).command(:delete).call
      end


      # 以下は未整理

      def find_by_service_attr(service_id, attr_id)
        mappings.where(service_id: service_id)
          .where(attr_id: attr_id)
          .one
      end

      def by_service_with_attr(service_id)
        aggregate(:attr)
          .where(service_id: service_id)
          .map_to(Mapping)
      end
    end
  end
end
