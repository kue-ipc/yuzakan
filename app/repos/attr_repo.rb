# frozen_string_literal: true

module Yuzakan
  module Repos
    class AttrRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, **CREATE_TIMESTAMP
      commands update: :by_pk, **UPDATE_TIMESTAMP
      commands delete: :by_pk
      def all = attrs.to_a
      def find(id) = attrs.by_pk(id).one
      def first = attrs.first
      def last = attrs.last
      def clear = attrs.delete

      # common interfaces
      private def by_name(name) = attrs.by_name(name)
      def get(name) = by_name(name).one
      private def set_update(name, **) = by_name(name).command(:update, **UPDATE_TIMESTAMP).call(**)
      def set(name, **) = set_update(name, **) || create(name: name, **)
      def unset(name) = by_name(name).command(:delete).call
      def exist?(name) = by_name(name).exist?
      def list = attrs.pluck(:name)

      # other interfaces
      def get_with_mappings(name)
        by_name(name).combine(mappings: :service).one
      end

      def create_with_mappings(**)
        attrs.combine(:mappings).command(:create, **CREATE_TIMESTAMP).call(**)
      end

      # なにもない場合は 0 を返す。
      def last_order(category)
        attrs.where(category: category).order(:order).pluck(:order).last.to_i
      end

      def renumber_order(attr)
        return 0 if attrs.where(category: attr.category, order: attr.order).count < 2

        count = 0
        transaction do
          # OPTIMIZE: N+1 問題があるが、ROMではこの方法しかない。
          attrs.exclude(id: attr.id)
            .where(category: attr.category) { order >= attr.order }
            .order(:order, :name).each.with_index do |a, idx|
            new_order = attr.order + idx + 1
            next if a.order == new_order

            update(a.id, order: new_order)
            count += 1
          end
        end
        count
      end

      # TODO: 個々から下は未整理

      def find_by_name(name)
        by_name(name).one
      end

      def ordered_all
        attrs.order(:order, :name).to_a
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
