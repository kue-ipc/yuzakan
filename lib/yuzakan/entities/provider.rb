require_relative '../utils/cache_store'

class Provider < Hanami::Entity
  attr_reader :params

  # attr_reader :adapter, :cache_store, :adapter_class

  NAME_RE = /\A[\w.-]+\z/.freeze

  BASE_ATTRS = %i[
    name
    display_name
    email
    locked
    disabled
    unmanageable
  ]

  class NoAdapterError < StandardError
    def initialize(msg = 'No adapter, but need an adapter.')
      super
    end
  end

  def initialize(attributes = nil)
    unless attributes
      super
      return
    end

    expires_in =
      case Hanami.env
      when 'test', 'development'
        0
      else
        60 * 60
      end
    namespace = ['yuzakan', 'provider', attributes[:name]].join(':')
    redis_url = ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/0')
    @cache_store ||= Yuzakan::Utils::CacheStore.create_store(
      expires_in: expires_in, namespace: namespace, redis_url: redis_url)

    @params = {}.tap do |data|
      ProviderRepository.params.each do |param_name|
        attributes[param_name]&.each do |param|
          data[param[:name].intern] = param[:value]
        end
      end
    end
    adapter_class = ADAPTERS.by_name(attributes[:adapter_name])
    raise NoAdapterError unless adapter_class

    @adapter = adapter_class.new(adapter_class.decrypt(@params))

    super
  end

  def safe_params
    @params.reject do |key, _value|
      adapter_param = @adapter.class.param_by_name(key)
      adapter_param.nil? || adapter_param[:encrypted]
    end
  end

  def decrypted_params
    params_decrypt(@params)
  end

  def params_encrypt(plain_params)
    @adapter.class.encrypt(plain_params)
  end

  def params_decrypt(encrypted_params)
    @adapter.class.decrypt(encrypted_params)
  end

  def adapter_label
    @adapter.class.label
  end

  def adapter_params
    @adapter.class.params
  end

  def user_key(username)
    ['user', username].join(':')
  end

  def group_key(groupname)
    ['group', groupname].join(':')
  end

  def user_list_key
    ['list', 'user'].join(':')
  end

  def group_list_key
    ['list', 'group'].join(':')
  end

  # Ruby attrs -> Adapter aatrs
  def map_attrs(attrs)
    mapped_attrs = attrs.slice(*Provider::BASE_ATTRS)
    attr_mappings.each do |mapping|
      value = attrs[mapping.attr_name]
      next if value.nil?

      mapped_attrs[mapping.name] = mapping.convert_value(value)
    end
    mapped_attrs
  end

  # Adapter attrs -> Ruby attrs
  def convert_attrs(raw_attrs)
    return nil if raw_attrs.nil?

    attrs = raw_attrs.slice(*Provider::BASE_ATTRS)
    attr_mappings.each do |mapping|
      value = raw_attrs[mapping.name] || raw_attrs[mapping.name.downcase]
      next if value.nil?

      attrs[mapping.attr_name] = mapping.map_value(value)
    end
    attrs
  end

  def need_adapter
    raise NoAdapterError unless @adapter
  end

  def sanitize_name(name)
    raise ArgumentError, 'invalid name' unless name =~ Provider::NAME_RE

    name.downcase(:ascii)
  end

  def check
    need_adapter

    @adapter.check
  end

  def create(username, password = nil, **attrs)
    need_adapter

    username = sanitize_name(username)
    mapped_attrs = map_attrs(attrs)

    raw_attrs = @adapter.create(username, password, **mapped_attrs)
    @cache_store[user_key(username)] = convert_attrs(raw_attrs) if raw_attrs
  end

  def read(username)
    need_adapter

    username = sanitize_name(username)

    @cache_store.fetch(user_key(username)) do
      raw_attrs = @adapter.read(username)
      @cache_store[user_key(username)] = convert_attrs(raw_attrs) if raw_attrs
    end
  end

  def udpate(username, **attrs)
    need_adapter

    username = sanitize_name(username)
    mapped_attrs = map_attrs(attrs)

    raw_attrs = @adapter.update(username, **mapped_attrs)
    @cache_store[user_key(username)] = convert_attrs(raw_attrs) if raw_attrs
  end

  def delete(username)
    need_adapter

    username = sanitize_name(username)

    raw_attrs = @adapter.delete(username)
    @cache_store.delete(user_key(username)) || convert_attrs(raw_attrs)
  end

  def auth(username, password)
    need_adapter

    username = sanitize_name(username)

    raw_attrs = @adapter.auth(username, password)
    @cache_store[user_key(username)] = convert_attrs(raw_attrs) if raw_attrs
  end

  def change_password(username, password)
    need_adapter
    username = sanitize_name(username)

    raw_attrs = @adapter.change_password(username, password)
    @cache_store[user_key(username)] = convert_attrs(raw_attrs) if raw_attrs
  end

  def lock(username)
    need_adapter
    username = sanitize_name(username)

    raw_attrs = @adapter.lock(username)
    @cache_store[user_key(username)] = convert_attrs(raw_attrs) if raw_attrs
  end

  def unlock(username, password = nil)
    need_adapter
    raw_attrs = @adapter.unlock(username, password)
    @cache_store[user_key(username)] = convert_attrs(raw_attrs) if raw_attrs
  end

  def generate_code(username)
    need_adapter
    @adapter.generate_code(username)
  end

  def admin?(username)
    read(username)[:admin]
  end

  def enabled?(username)
    !read(username)[:disabled]
  end

  def locked?(username)
    !!read(username)[:locked]
  end

  def disabled?(username)
    !!read(username)[:disabled]
  end

  def unmanageable?(username)
    !!read(username)[:unmanageable]
  end

  def list
    need_adapter

    @cache_store.fetch(user_list_key) do
      @cache_store[user_list_key] = @adapter.list
    end
  end
end
