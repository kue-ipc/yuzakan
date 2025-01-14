# frozen_string_literal: true

module Yuzakan
  module Providers
    class ConvertData < Yuzakan::Operation
      include Deps[
        "repos.attr_mapping_repo",
      ]

      def call(provider, data, category: :user)
        mappings = step get_mappings(provider, category)
        hash = step convert_data_with_mappings(data, mappings)
        if categroy == :user && !provider.has_group?
          hash.except!(:primary_group, :groups)
        end
        hash
      end

      private def get_mappings(provider, category)
        mappings =
          if provider.attr_mappings.nil?
            attr_mapping_repo.all_by_provider(provider, category:)
          else
            provider.attr_mappings
              .select { |mapping| mapping.category_of?(category) }
          end
        Success(mappings)
      end

      private def convert_data(data, mappings)
        return Success(nil) if data.nil?

        attrs = mappings.to_h do |mapping|
          value = data.attrs[mapping.key]
          [mapping.attr.name, mapping.convert_value(value)]
        end.compact # 値がnilの場合は除外する

        Success({**data.to_h, attrs:})
      end
    end
  end
end
