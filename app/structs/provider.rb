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
        super.except(:mappings)
      end

      # TODO: ここから下はたぶんほとんど移動すべき

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

        mappings
          .reject { |mapping| mapping.attr.readonly } # 読み取り専用の属性は除外する
          .to_h do |mapping|
          [mapping.key,
            mapping.map_value(attrs[mapping.attr.name.intern]),]
        end
          .compact # 値がnilの場合は除外する
      end

      # Ruby userdata -> Adapter userdata
      private def map_userdata(userdata)
        return if userdata.nil?

        userdata = userdata.except(:primary_group, :groups) unless has_group?

        {**userdata, attrs: map_attrs(userdata[:attrs])}
      end

      def need_adapter!
        raise NoAdapterError unless @adapter
      end

      def need_mappings!
        raise NoMappingsError unless mappings
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
          @cache_store[user_key(username)] =
            raw_userdata && convert_userdata(raw_userdata)
        end
      end

      def user_update(username, **userdata)
        need_adapter!
        need_mappings!

        raw_userdata = @adapter.user_update(username, **map_userdata(userdata))
        @cache_store[user_key(username)] =
          raw_userdata && convert_userdata(raw_userdata)
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
          @cache_store[member_list_key(groupname)] =
            @adapter.member_list(groupname)
        end
      end

      def can_do?(method)
        abilities = Provider.abilities_to(method)
        abilities.all? { |name| __send__(name) }
      end

      def self.abilities_to(method)
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
