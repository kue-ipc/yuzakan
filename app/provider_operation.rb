# auto_register: false
# frozen_string_literal: true

module Yuzakan
  class ProviderOperation < Yuzakan::Operation
    def self.category(name)
      define_method(:category) do
        name
      end
    end

    include Deps[
      "adapter_map",
      "cache_store",
      "repos.mapping_repo",
      "repos.provider_repo"
  ]

    # common flows

    private def get_provider(provider)
      case provider
      in nil
        Failure([:nil, "provider"])
      in Yuzakan::Structs::Provider
        Success(provider)
      in String | Symbol
        if (struct = provider_repo.get(provider))
          Success(struct)
        else
          Failure([:not_found, "provider"])
        end
      end
    end

    private def get_providers(providers = nil, method: nil)
      case providers
      in nil
        Success(provider_repo.all_callable(method))
      in []
        Success([])
      in [String | Symbol, *]
        Success(provider_repo.mget(*providers).select { |provider| provider.can_do?(method) })
      in [Yuzakan::Structs::Provider, *]
        Success(providers.select { |provider| provider.can_do?(method) })
      else
        Failure([:not_provider_list])
      end
    end

    private def get_adapter(provider)
      adapter_class = adapter_map[provider.adapter]
      return Failure([:not_found, "adapter"]) if adapter_class.nil?

      begin
        adapter = adapter_class.new(provider.params, group: provider.group,
          logger: logger)
        Success(adapter)
      rescue => e
        Failure([:error, e])
      end
    end

    private def get_mappings(provider, category: self.category)
      mappings =
        if provider.respond_to?(:mappings) &&
            (provider.mappings.empty? ||
            provider.mappings.first.respond_to?(:attr))
          provider.mappings
        else
          mapping_repo.all_with_attrs_by_provider(provider)
        end
      mappings.select { |mapping| mapping.category_of?(category) } if category

      Success(mappings)
    end

    # Adapter data (*Data) -> Hanami params (Hash)
    private def convert_data(provider, data, category: self.category)
      return Success(nil) if data.nil?

      if data.attrs.nil? || data.attrs.empty?
        attrs = data.attrs
      else
        mappings = get_mappings(provider, category:)
          .value_or { return Failure(_1) }
        attrs = convert_attrs(mappings, data.attrs)
          .value_or { return Failure(_1) }
      end

      group_params =
        if category == :user && !provider.has_group?
          {primary_group: data.primary_group, groups: data.groups}
        else
          {}
        end

      Success({
        **data.to_h.except(:attrs, :primary_group, :groups),
        **group_params,
        attrs: attrs,
      })
    end

    # Hanami params (Hash) -> Adapter data (*Data)
    def map_data(provider, params, category: self.category)
      return Success(nil) if params.nil?

      if params[:attrs].nil? || params[:attrs].empty?
        attrs = params[:attrs]
      else
        mappings = get_mappings(provider, category:)
          .value_or { return Failure(_1) }
        attrs = map_attrs(mappings, data.attrs)
          .value_or { return Failure(_1) }
      end

      case category
      in :user
        keys = [:display_name, :email]
        keys.push(:primary_group, :groups) if provider.has_group?
        Success(Yuzakan::Adapter::UserData.new(**params.slice(*keys), attrs:))
      in :group
        keys = [:display_name]
        Success(Yuzakan::Adapter::GroupData.new(**params.slice(*keys), attrs:))
      else
        Failure([:unknown, "category"])
      end
    end

    private def convert_attrs(mappings, attrs)
      return Success(nil) if attrs.nil?

      converted_attrs = mappings
        .select { |mapping| attrs.key?(mapping.key) }
        .to_h { |mapping| [mapping.attr.name, mapping.convert_value(attrs[mapping.key])] }
      Success(converted_attrs)
    end

    private def map_attrs(mappings, attrs)
      return Success(nil) if attrs.nil?

      mapped_attrs = mappings
        .reject(&:readonly) # exclude read-only
        .select { |mapping| attrs.key?(mapping.attr.name) }
        .to_h { |mapping| [mapping.key, mapping.map_value(attrs[mapping.attr.name])] }
      Success(mapped_attrs)
    end

    # common fuctions

    private def cache_key(provider, name = nil, category: self.category)
      if name
        "provider:#{provider.name}:#{category}:#{name}"
      else
        "provider:#{provider.name}:list:#{category}"
      end
    end

    private def cache_read(provider, name = nil, category: self.category)
      cache_store.read(cache_key(provider, name, category:))
    end

    private def cache_write(provider, name = nil, category: self.category)
      cache_store.write(cache_key(provider, name, category:), yield)
    end

    private def cache_fetch(provider, name = nil, category: self.category, &)
      cache_store.fetch(cache_key(provider, name, category:), &)
    end

    private def cache_delete(provider, name = nil, category: self.category)
      pp provider
      cache_store.delete(cache_key(provider, name, category:))
    end

    private def cache_exist?(provider, name = nil, category: self.category)
      cache_store.exist?(cache_key(provider, name, category:))
    end
  end
end
