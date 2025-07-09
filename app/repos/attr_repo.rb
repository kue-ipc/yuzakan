# frozen_string_literal: true

module Yuzakan
  module Repos
    class AttrRepo < Yuzakan::DB::Repo
      private def by_name(name)
        attrs.where(name: name)
      end

      def find_by_name(name)
        by_name(name).one
      end

      def exist_by_name?(name)
        by_name(name).exist?
      end

      def ordered_all
        attrs.order(:order, :name).to_a
      end

      def last_order
        attrs.order(:order).last&.fetch(:order).to_i
      end

      def ordered_all_with_mappings
        aggregate(mappings: :service).order(:order,
          :name).map_to(Attr).to_a
      end

      def find_with_mappings(id)
        aggregate(mappings: :service).where(id: id).map_to(Attr).one
      end

      def find_with_mappings_by_name(name)
        aggregate(mappings: :service).where(name: name).map_to(Attr).one
      end

      def create_with_mappings(data)
        assoc(:mappings).create(data)
      end

      def add_mapping(attr, data)
        assoc(:mappings, attr).add(data)
      end

      def delete_mapping(attr, id)
        mapping_for(attr, id).delete
      end

      def mapping_for(attr, id)
        assoc(:mappings, attr).where(id: id)
      end

      private def mapping_by_service_id(attr, service_id)
        assoc(:mappings, attr).where(service_id: service_id)
      end

      def delete_mapping_by_service_id(attr, service_id)
        mapping_by_service_id(attr, service_id).delete
      end

      def find_mapping_by_service_id(attr, service_id)
        mapping_by_service_id(attr, service_id).to_a.first
      end
    end
  end
end
