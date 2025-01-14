# frozen_string_literal: true

module Yuzakan
  module Providers
    # Adapter data (*Data) -> Hanami params (Hash)

    class ConvertData < Yuzakan::ProviderOperation
      include Deps[
        "repos.attr_mapping_repo",
      ]

      def call(provider, data, category:)
        return if data.nil?

        provider = step get_provider(provider)
        mappings = step get_mappings(provider, category)
        attrs = step convert_attrs(mappings, data.attrs)

        params = data.to_h.except(:attrs)
        params[:attrs] = attrs
        if category == :user && !provider.has_group?
          params.except!(:primary_group, :groups)
        end
        params
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

      private def convert_attrs(mappings, attrs)
        return Success(nil) if attrs.nil?

        mappings.to_h do |mapping|
          [mapping.attr.name, mapping.convert_value(attrs[mapping.key])]
        end.compact.then { Success(_1) }
      end
    end
  end
end
