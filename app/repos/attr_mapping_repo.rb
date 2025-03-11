# frozen_string_literal: true

module Yuzakan
  module Repos
    class AttrMappingRepo < Yuzakan::DB::Repo
      def all_with_attrs_by_provider(provider)
        attr_mappings.by_provider_id(provider.id).combine(:attrs).to_a
      end

      # 以下は未整理

      def find_by_provider_attr(provider_id, attr_id)
        attr_mappings.where(provider_id: provider_id)
          .where(attr_id: attr_id)
          .one
      end

      def by_provider_with_attr(provider_id)
        aggregate(:attr)
          .where(provider_id: provider_id)
          .map_to(AttrMapping)
      end
    end
  end
end
