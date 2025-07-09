# frozen_string_literal: true

module Yuzakan
  module Repos
    class MappingRepo < Yuzakan::DB::Repo
      def all_with_attrs_by_service(service)
        mappings.by_service_id(service.id).combine(:attrs).to_a
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
