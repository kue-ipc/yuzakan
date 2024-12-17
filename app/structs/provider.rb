# frozen_string_literal: true

require "digest/md5"

# TODO: ばらばらにする。

# rubocop: disable Metrics/ClassLength
module Yuzakan
  module Structs
    class Provider < Yuzakan::DB::Struct
      class NoAdapterError < StandardError
        def initialize(msg = "No adapter, but need an adapter.")
          super
        end
      end

      class NoMappingsError < StandardError
        def initialize(msg = "No mappings, but need mappings.")
          super
        end
      end

      class NoGroupError < StandardError
        def initialize(msg = "Cannot manage group.")
          super
        end
      end

      # FIXME: adapterはoperationsで作る
      # @adapter_class, @cache_store, @params, @adapterを使用するメソッドはそちらに移動すること。

      def label_name
        if display_name
          "#{display_name} (#{name})"
        else
          name
        end
      end

      def label
        display_name || name
      end

      def to_h
        super.except(:provider_params, :attr_mappings)
      end

      def safe_params
        @params.reject do |key, _value|
          param_type = @adapter_class.param_type_by_name(key)
          param_type.nil? || param_type.encrypted?
        end
      end

      def adapter_label
        @adapter_class.label
      end

      def adapter_param_types
        @adapter_class.param_types
      end

      def key(*name)
        name.join(":")
      end

      def user_key(username)
        key("user", username)
      end

      def group_key(groupname)
        key("group", groupname)
      end

      def list_key(name, *others)
        key("list", name, *others)
      end

      def user_list_key
        list_key("user")
      end

      def group_list_key
        list_key("group")
      end

      def member_list_key(groupname)
        list_key("member", groupname)
      end

      def user_search_key_raw(name)
        key("search", "user", name)
      end

      def user_search_key(query)
        user_search_key_raw(Digest::MD5.hexdigest(query))
      end

      def group_search_key_raw(name)
        key("search", "group", name)
      end

      def group_search_key(query)
        group_search_key_raw(Digest::MD5.hexdigest(query))
      end

      def clear_user_list_cache
        @cache_store.delete(user_list_key)
        @cache_store.delete_matched(user_search_key_raw("*"))
      end

      def clear_group_list_cache
        @cache_store.delete(group_list_key)
        @cache_store.delete_matched(group_search_key_raw("*"))
      end

      # Ruby attrs -> Adapter aatrs
      private def map_attrs(attrs)
        return {} if attrs.nil?

        attr_mappings
          .reject { |mapping| mapping.attr.readonly } # 読み取り専用の属性は除外する
          .to_h { |mapping| [mapping.key, mapping.map_value(attrs[mapping.attr.name.intern])] }
          .compact # 値がnilの場合は除外する
      end

      # Ruby userdata -> Adatper userdata
      private def map_userdata(userdata)
        return if userdata.nil?

        userdata = userdata.except(:primary_group, :groups) unless has_group?

        {**userdata, attrs: map_attrs(userdata[:attrs])}
      end

      # Adapter attrs -> Ruby attrs
      private def convert_attrs(raw_attrs)
        return {} if raw_attrs.nil?

        attr_mappings.to_h do |mapping|
          raw_value = raw_attrs[mapping.key] || raw_attrs[mapping.key.downcase]
          [mapping.attr.name, mapping.convert_value(raw_value)]
        end.compact # 値がnilの場合は除外する
      end

      # Adapter userdata -> Ruby userdata
      private def convert_userdata(raw_userdata)
        return if raw_userdata.nil?

        raw_userdata = raw_userdata.except(:primary_group, :groups) unless has_group?

        {**raw_userdata, attrs: convert_attrs(raw_userdata[:attrs])}
      end

      def need_adapter!
        raise NoAdapterError unless @adapter
      end

      def need_mappings!
        raise NoMappingsError unless attr_mappings
      end

      def need_group!
        raise NoGroupError unless group
      end

      def check
        need_adapter!
        @adapter.check
      end

      def user_create(username, password = nil, **userdata)
        need_adapter!
        need_mappings!

        raw_userdata =
          @adapter.user_create(username, password, **map_userdata(userdata))
        clear_user_list_cache
        @cache_store[user_key(username)] = convert_userdata(raw_userdata)
      end

      def user_read(username)
        need_adapter!
        need_mappings!

        @cache_store.fetch(user_key(username)) do
          raw_userdata = @adapter.user_read(username)
          @cache_store[user_key(username)] = raw_userdata && convert_userdata(raw_userdata)
        end
      end

      def user_update(username, **userdata)
        need_adapter!
        need_mappings!

        raw_userdata = @adapter.user_update(username, **map_userdata(userdata))
        @cache_store[user_key(username)] = raw_userdata && convert_userdata(raw_userdata)
      end

      def user_delete(username)
        need_adapter!
        need_mappings!

        raw_userdata = @adapter.user_delete(username)
        return if raw_userdata.nil?

        @cache_store[user_key(username)] = nil
        clear_user_list_cache
        convert_userdata(raw_userdata)
      end

      def user_auth(username, password)
        need_adapter!

        @adapter.user_auth(username, password)
      end

      def user_change_password(username, password)
        need_adapter!

        @adapter.user_change_password(username, password)
      end

      def user_generate_code(username)
        need_adapter!

        @adapter.user_generate_code(username)
      end

      def user_lock(username)
        need_adapter!
        need_mappings!

        @adapter.user_lock(username).tap do |result|
          @cache_store.delete(user_key(username)) if result
        end
      end

      def user_unlock(username, password = nil)
        need_adapter!

        @adapter.user_unlock(username, password).tap do |result|
          @cache_store.delete(user_key(username)) if result
        end
      end

      def user_locked?(username)
        read(username)&.fetch(:locked, false)
      end

      def user_unmanageable?(username)
        read(username)&.fetch(:unmanageable, false)
      end

      def user_list
        need_adapter!
        @cache_store.fetch(user_list_key) do
          @cache_store[user_list_key] = @adapter.user_list
        end
      end

      def user_search(query)
        need_adapter!
        @cache_store.fetch(user_search_key(query)) do
          @cache_store[user_search_key(query)] = @adapter.user_search(query)
        end
      end

      def group_read(groupname)
        need_adapter!
        need_group!
        @cache_store.fetch(group_key(groupname)) do
          groupdata = @adapter.group_read(groupname)
          groupdata = {primary: true}.merge(groupdata) if groupdata && has_primary_group?
          @cache_store[group_key(groupname)] = groupdata
        end
      end

      def group_list
        need_adapter!
        need_group!
        @cache_store.fetch(group_list_key) do
          @cache_store[group_list_key] = @adapter.group_list
        end
      end

      def group_search(query)
        need_adapter!
        need_group!
        @cache_store.fetch(group_search_key(query)) do
          @cache_store[group_search_key(query)] = @adapter.group_search(query)
        end
      end

      def member_list(groupname)
        need_adapter!
        need_group!
        @cache_store.fetch(member_list_key(groupname)) do
          @cache_store[member_list_key(groupname)] = @adapter.member_list(groupname)
        end
      end

      def can_do?(operation)
        ability = Provider.operation_ability(operation)
        ability.all? do |name, value|
          __send__(name) == value
        end
      end

      def self.operation_ability(operation)
        case operation
        when :check
          {}
        when :user_create, :user_update, :user_delete
          {writable: true}
        when :user_read, :user_list, :user_seacrh
          {readable: true}
        when :user_auth
          {authenticatable: true}
        when :user_change_password, :user_generate_code
          {password_changeable: true}
        when :user_lock, :user_unlock
          {lockable: true}
        when :group_read, :group_list, :member_list
          {group: true, readable: true}
        when :member_add, :member_remove
          {group: true, writable: true}
        else
          raise "不明な操作です。#{operation}"
        end
      end

      def has_group?
        group
      end

      def has_primary_group?
        has_group? && @adapter_class.has_primary_group?
      end
    end
  end
end
# rubocop: enable Metrics/ClassLength
