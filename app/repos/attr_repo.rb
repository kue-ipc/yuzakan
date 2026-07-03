# frozen_string_literal: true

module Yuzakan
  module Repos
    class AttrRepo < Yuzakan::DB::Repo
      private def with_all(relation) = relation.combine(mappings: :service)

      # other interfaces
      # def get_with_mappings(name) = by_name(name).combine(:mappings).one
      # def get_with_mappings_and_services(name) = by_name(name).combine(mappings: :service).one
      # def create_with_mappings(**) = attrs.combine(:mappings).command(:create, **CREATE_TIMESTAMP).call(**)

      # return 0 if empty
      def last_order = attrs.pluck(:order).last.to_i

      def renumber_order(attr)
        return 0 if attrs.where(order: attr.order).count < 2

        count = 0
        transaction do
          # OPTIMIZE: N+1 問題があるが、ROMではこの方法しかない。
          attrs.exclude(id: attr.id)
            .where { order >= attr.order }
            .each.with_index do |a, idx|
            new_order = attr.order + idx + 1
            next if a.order == new_order

            update(a.id, order: new_order)
            count += 1
          end
        end
        count
      end

      def exposed_all = attrs.where(hidden: false).to_a

      def all_for_category(category) = attrs.by_category(category).to_a

      # TODO: 個々から下は未整理

      # def gets(names) = by_name(names).to_a

      # def find_by_name(name)
      #   by_name(name).one
      # end

      # def ordered_all
      #   attrs.order(:order, :name).to_a
      # end

      # def ordered_all_with_mappings
      #   aggregate(mappings: :service).order(:order,
      #     :name).map_to(Attr).to_a
      # end

      # def find_with_mappings(id)
      #   aggregate(mappings: :service).where(id: id).map_to(Attr).one
      # end

      # def find_with_mappings_by_name(name)
      #   aggregate(mappings: :service).where(name: name).map_to(Attr).one
      # end

      # def add_mapping(attr, data)
      #   assoc(:mappings, attr).add(data)
      # end

      # def delete_mapping(attr, id)
      #   mapping_for(attr, id).delete
      # end

      # def mapping_for(attr, id)
      #   assoc(:mappings, attr).where(id: id)
      # end

      # private def mapping_by_service_id(attr, service_id)
      #   assoc(:mappings, attr).where(service_id: service_id)
      # end

      # def delete_mapping_by_service_id(attr, service_id)
      #   mapping_by_service_id(attr, service_id).delete
      # end

      # def find_mapping_by_service_id(attr, service_id)
      #   mapping_by_service_id(attr, service_id).to_a.first
      # end
    end
  end
end
