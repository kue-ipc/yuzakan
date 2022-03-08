require_relative '../utils/cache_store'

class Provider < Hanami::Entity
  attr_reader :params

  NAME_RE = /\A[\w.-]+\z/.freeze

  class NoAdapterError < StandardError
    def initialize(msg = 'No adapter, but need an adapter.')
      super
    end
  end

  def initialize(attributes = nil)
    if attributes.nil? || attributes[:adapter_name].nil?
      super
      return
    end

    @adapter_class = ADAPTERS_MANAGER.by_name(attributes[:adapter_name])
    raise NoAdapterError, "Not found adapter: #{attributes[:adapter_name]}" unless @adapter_class

    if attributes[:provider_params].nil?
      super
      return
    end

    # cache_store
    expires_in =
      if Hanami.env == 'production'
        60 * 60
      else
        0
      end
    namespace = ['yuzakan', 'provider', attributes[:name]].join(':')
    redis_url = ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/0')
    @cache_store = Yuzakan::Utils::CacheStore.create_store(expires_in: expires_in, namespace: namespace,
                                                           redis_url: redis_url)

    provider_params_hash = attributes[:provider_params].to_h do |param|
      [param[:name].intern, param[:value]]
    end
    @params = @adapter_class.normalize_params(provider_params_hash)
    @adapter = @adapter_class.new(@params)
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
      [mapping.attr_name, mapping.map_value(raw_attrs[mapping.name] || raw_attrs[mapping.name.downcase])]
    end.compact
  end

  def convert_userdata(raw_userdata)
    return if raw_userdata.nil?

    {**raw_userdata, attrs: convert_attrs(raw_userdata[:attrs])}
  end

  def need_adapter!
    raise NoAdapterError unless @adapter
  end

  def sanitize_name(name)
    raise ArgumentError, 'invalid name' unless name =~ Provider::NAME_RE

    name.downcase(:ascii)
  end

  def check
    need_adapter!
    @adapter.check
  end

  def create(username, password = nil, **userdata)
    need_adapter!
    username = sanitize_name(username)
    raw_userdata = @adapter.create(username, password, **map_userdata(userdata))
    @cache_store[user_key(username)] = convert_userdata(raw_userdata) if raw_userdata
  end

  def read(username)
    need_adapter!
    username = sanitize_name(username)
    @cache_store.fetch(user_key(username)) do
      raw_userdata = @adapter.read(username)
      @cache_store[user_key(username)] = convert_userdata(raw_userdata) if raw_userdata
    end
  end

  def udpate(username, **userdata)
    need_adapter!
    username = sanitize_name(username)
    raw_userdata = @adapter.update(username, **map_userdata(userdata))
    @cache_store[user_key(username)] = convert_userdata(raw_userdata) if raw_userdata
  end

  def delete(username)
    need_adapter!
    username = sanitize_name(username)
    raw_userdata = @adapter.delete(username)
    @cache_store.delete(user_key(username)) || convert_userdata(raw_userdata)
  end

  def auth(username, password)
    need_adapter!
    username = sanitize_name(username)
    raw_userdata = @adapter.auth(username, password)
    @cache_store[user_key(username)] = convert_userdata(raw_userdata) if raw_userdata
  end

  def change_password(username, password)
    need_adapter!
    username = sanitize_name(username)
    raw_userdata = @adapter.change_password(username, password)
    @cache_store[user_key(username)] = convert_userdata(raw_userdata) if raw_userdata
  end

  def lock(username)
    need_adapter!
    username = sanitize_name(username)
    raw_userdata = @adapter.lock(username)
    @cache_store[user_key(username)] = convert_userdata(raw_userdata) if raw_userdata
  end

  def unlock(username, password = nil)
    need_adapter!
    username = sanitize_name(username)
    raw_userdata = @adapter.unlock(username, password)
    @cache_store[user_key(username)] = convert_userdata(raw_userdata) if raw_userdata
  end

  def generate_code(username)
    need_adapter!
    username = sanitize_name(username)
    @adapter.generate_code(username)
  end

  def enabled?(username)
    !read(username)[:disabled]
  end

  def locked?(username)
    nil | read(username)[:locked]
  end

  def disabled?(username)
    nil | read(username)[:disabled]
  end

  def unmanageable?(username)
    nil | read(username)[:unmanageable]
  end

  def list
    need_adapter!
    @cache_store.fetch(user_list_key) do
      @cache_store[user_list_key] = @adapter.list
    end
  end
end
