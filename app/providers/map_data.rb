# frozen_string_literal: true

module Yuzakan
  module Providers
    # Hanami params (Hash) -> Adapter data (*Data)

    class MapData < Yuzakan::ProviderOperation
      include Deps[
        "repos.attr_mapping_repo",
      ]

      def call(provider, params, category:)
        provider = step get_provider(provider)
        mappings = step get_mappings(provider, category)
        attrs = step map_attrs(mappings, params[:attrs])

        case category
        in :user
          keys = [:display_name, :email]
          keys.push(:primary_group, :groups) if provider.has_group?
          Yuzakan::Adapter::UserData.new(**params.slice(*keys), attrs:)
        in :group
          keys = [:display_name]
          Yuzakan::Adapter::GroupData.new(**params.slice(*keys), attrs:)
        end
      end

      private def get_mappings(provider, category)
        mappings =
          if provider.respond_to?(:attr_mappings)
            provider.attr_mappings
          else
            attr_mapping_repo.all_with_attrs_by_provider(provider)
          end.select { |mapping| mapping.category_of?(category) }

        Success(mappings)
      end

      private def map_attrs(mappings, attrs)
        return Success(nil) if attrs.nil?

        mappings
          .reject { |mapping| mapping.attr.readonly } # exclude read-only
          .to_h do |mapping|
          [mapping.key, mapping.map_value(attrs[mapping.attr.name])]
        end.compact.then { Success(_1) }
      end
    end
  end
end
