require 'digest/md5'
require_relative '../utils/cache_store'

class Provider < Hanami::Entity
  attr_reader :params

  class NoAdapterError < StandardError
    def initialize(msg = 'No adapter, but need an adapter.')
      super
    end
  end

  class NoMappingsError < StandardError
    def initialize(msg = 'No mappings, but need mappings.')
      super
    end
  end

  class NoGroupError < StandardError
    def initialize(msg = 'Cannot manage group.')
      super
    end
  end

  def initialize(attributes = nil)
    return super if attributes.nil? || attributes[:adapter_name].nil? # rubocop:disable Lint/ReturnInVoidContext

    @adapter_class = ADAPTERS_MANAGER.by_name(attributes[:adapter_name])
    unless @adapter_class
      raise NoAdapterError, "Not found adapter: #{attributes[:adapter_name]}"
    end

    return super if attributes[:provider_params].nil? # rubocop:disable Lint/ReturnInVoidContext

    # cache_store
    expires_in = case Hanami.env
                 when 'production' then 60 * 60
                 when 'development' then 60
                 else 0
                 end
    namespace = ['yuzakan', 'provider', attributes[:name]].join(':')
    redis_url = ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/0')
    @cache_store = Yuzakan::Utils::CacheStore.create_store(
      expires_in: expires_in, namespace: namespace, redis_url: redis_url)

    provider_params_hash = attributes[:provider_params].to_h do |param|
      [param[:name].intern, param[:value]]
    end
    @params = @adapter_class.normalize_params(provider_params_hash)
    @adapter = @adapter_class.new(@params, logger: Hanami.logger)
    super
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
    name.join(':')
  end

  def user_key(username)
    key('user', username)
  end

  def group_key(groupname)
    key('group', groupname)
  end

  def list_key(name)
    key('list', name)
  end

  def user_list_key
    list_key('user')
  end

  def group_list_key
    list_key('group')
  end

  def user_search_key_raw(name)
    key('search', 'user', name)
  end

  def user_search_key(query)
    user_search_key_raw(Digest::MD5.hexdigest(query))
  end

  def clear_user_list_cache
    @cache_store.delete(user_list_key)
    @cache_store.delete_matched(user_search_key_raw('*'))
  end

  # Ruby attrs -> Adapter aatrs
  def map_attrs(attrs)
    return {} if attrs.nil?

    attr_mappings.to_h do |mapping|
      [mapping.name, mapping.convert_value(attrs[mapping.attr_name])]
    end.compact
  end

  def map_userdata(userdata)
    return if userdata.nil?

    {**userdata, attrs: map_attrs(userdata[:attrs])}
  end

  # Adapter attrs -> Ruby attrs
  def convert_attrs(raw_attrs)
    return {} if raw_attrs.nil?

    attr_mappings.to_h do |mapping|
      raw_value = raw_attrs[mapping.name] || raw_attrs[mapping.name.downcase]
      [mapping.attr_name, mapping.map_value(raw_value)]
    end.compact
  end

  def convert_userdata(raw_userdata)
    return if raw_userdata.nil?

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
      @cache_store[user_key(username)] =
        raw_userdata && convert_userdata(raw_userdata)
    end
  end

  def user_udpate(username, **userdata)
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
    @cache_store[user_key(username)] = nil
    return if raw_userdata.nil?

    clear_user_list_cache
    convert_userdata(raw_userdata)
  end

  def user_auth(username, password)
    need_adapter!
    need_mappings!

    @adapter.user_auth(username, password)
  end

  def user_change_password(username, password)
    need_adapter!
    need_mappings!

    raw_userdata = @adapter.user_change_password(username, password)
    if raw_userdata
      @cache_store[user_key(username)] = convert_userdata(raw_userdata)
    end
  end

  def user_generate_code(username)
    need_adapter!

    @adapter.user_generate_code(username)
  end

  def user_lock(username)
    need_adapter!
    need_mappings!

    raw_userdata = @adapter.user_lock(username)
    if raw_userdata
      @cache_store[user_key(username)] =
        convert_userdata(raw_userdata)
    end
  end

  def user_unlock(username, password = nil)
    need_adapter!
    need_mappings!

    raw_userdata = @adapter.user_unlock(username, password)
    if raw_userdata
      @cache_store[user_key(username)] =
        convert_userdata(raw_userdata)
    end
  end

  def user_enabled?(username)
    !read(username)[:disabled]
  end

  def user_locked?(username)
    nil | read(username)[:locked]
  end

  def user_disabled?(username)
    nil | read(username)[:disabled]
  end

  def user_unmanageable?(username)
    nil | read(username)[:unmanageable]
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
end
