# auto_register: false
# frozen_string_literal: true

module Yuzakan
  class ServiceOperation < Yuzakan::Operation
    def self.category(name)
      define_method(:category) do
        name
      end
    end

    include Deps[
      "adapter_map",
      "cache_store",
      "repos.mapping_repo",
      "repos.service_repo"
  ]

    # common flows

    private def get_service(service)
      case service
      in nil
        Failure([:nil, "service"])
      in Yuzakan::Structs::Service
        Success(service)
      in String | Symbol
        if (struct = service_repo.get(service))
          Success(struct)
        else
          Failure([:not_found, "service"])
        end
      end
    end

    private def get_services(services = nil, method: nil)
      abilities = abilities_to_call(method)

      case services
      in nil
        Success(service_repo.all_with_abilities(*abilities))
      in []
        Success([])
      in [String | Symbol, *]
        Success(service_repo.mget(*services).select { |service| abilities.all? { |name| service.__send__(name) } })
      in [Yuzakan::Structs::Service, *]
        Success(services.select { |service| abilities.all? { |name| service.__send__(name) } })
      else
        Failure([:not_service_list])
      end
    end

    def abilities_to_call(method)
      case method.intern.downcase
      in nil | :check
        []
      in :user_read | :user_list | :user_seacrh
        [:readable]
      in :user_create | :user_update | :user_delete
        [:writable]
      in :user_auth
        [:authenticatable]
      in :user_change_password | :user_generate_code
        [:password_changeable]
      in :user_reset_mfa | :user_generate_code
        [:mfa_changeable]
      in :user_lock | :user_unlock
        [:lockable]
      in :group_read | :group_list | :group_search | :member_list
        [:group, :readable]
      in :group_create | :group_update | :group_delete | :member_add | :member_remove
        [:group, :writable]
      end
    end

    private def get_adapter(service)
      adapter_class = adapter_map[service.adapter]
      return Failure([:not_found, "adapter"]) if adapter_class.nil?

      begin
        adapter = adapter_class.new(service.params, group: service.group,
          logger: logger)
        Success(adapter)
      rescue => e
        Failure([:error, e])
      end
    end

    private def get_mappings(service, category: self.category)
      mappings =
        if service.respond_to?(:mappings) &&
            (service.mappings.empty? ||
            service.mappings.first.respond_to?(:attr))
          service.mappings
        else
          mapping_repo.all_with_attrs_by_service(service)
        end
      mappings.select { |mapping| mapping.category_of?(category) } if category

      Success(mappings)
    end

    # Adapter data (*Data) -> Hanami params (Hash)
    private def convert_data(service, data, category: self.category)
      return Success(nil) if data.nil?

      if data.attrs.nil? || data.attrs.empty?
        attrs = data.attrs
      else
        mappings = get_mappings(service, category:)
          .value_or { return Failure(_1) }
        attrs = convert_attrs(mappings, data.attrs)
          .value_or { return Failure(_1) }
      end

      group_params =
        if category == :user && !service.has_group?
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
    def map_data(service, params, category: self.category)
      return Success(nil) if params.nil?

      if params[:attrs].nil? || params[:attrs].empty?
        attrs = params[:attrs]
      else
        mappings = get_mappings(service, category:).value_or { return Failure(_1) }
        attrs = map_attrs(mappings, data.attrs).value_or { return Failure(_1) }
      end

      case category
      in :user
        keys = [:label, :email]
        keys.push(:primary_group, :groups) if service.has_group?
        Success(Yuzakan::Adapter::UserData.new(**params.slice(*keys), attrs:))
      in :group
        keys = [:label]
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

    private def cache_key(service, name = nil, category: self.category)
      if name
        "service:#{service.name}:#{category}:#{name}"
      else
        "service:#{service.name}:list:#{category}"
      end
    end

    private def cache_read(service, name = nil, category: self.category)
      cache_store.read(cache_key(service, name, category:))
    end

    private def cache_write(service, name = nil, category: self.category)
      cache_store.write(cache_key(service, name, category:), yield)
    end

    private def cache_fetch(service, name = nil, category: self.category, &)
      cache_store.fetch(cache_key(service, name, category:), &)
    end

    private def cache_delete(service, name = nil, category: self.category)
      pp service
      cache_store.delete(cache_key(service, name, category:))
    end

    private def cache_exist?(service, name = nil, category: self.category)
      cache_store.exist?(cache_key(service, name, category:))
    end
  end
end
