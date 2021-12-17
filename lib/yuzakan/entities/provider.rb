require_relative '../utils/cache_store'

class Provider < Hanami::Entity
  attr_reader :params, :adapter, :adapter_class, :cache_store

  NAME_RE = /\A[\w.-]+\z/.freeze

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
      if Hanami.env == 'test'
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
        params = attributes[param_name]
        next if params.nil?

        params.each do |param|
          data[param[:name].intern] = param[:value]
        end
      end
    end
    @adapter_class = ADAPTERS.by_name(attributes[:adapter_name])
    @adapter = @adapter_class&.new(@params)

    super
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
    ['list', 'group']
  end

  def sanitize_name(name)
    raise ArgumentError, 'invalid name' unless name =~ Provider::NAME_RE

    name.downcase(:ascii)
  end

  def check
    raise NoAdapterError unless adapter

    adapter.check
  end

  def create(username, attrs, password)
    raise NoAdapterError unless adapter

    username = sanitize_name(username)

    adapter.create(username, attrs, attr_mappings, password).tap do |value|
      cache_store[user_key(username)] = value
    end
  end

  def read(username)
    raise NoAdapterError unless adapter

    username = sanitize_name(username)

    cache_store.fetch(user_key(username)) do
      adapter.read(username, attr_mappings).tap do |value|
        cache_store[user_key(username)] = value
      end
    end
  end

  def udpate(username, attrs)
    raise NoAdapterError unless adapter

    username = sanitize_name(username)

    adapter.update(username, attrs, attr_mappings).tap do |value|
      cache_store[user_key(username)] = value
    end
  end

  def delete(username)
    raise NoAdapterError unless adapter

    username = sanitize_name(username)

    adapter.delete(username)
    cache_store.delete(user_key(username))
  end

  def auth(username, password)
    raise NoAdapterError unless adapter

    username = sanitize_name(username)
    key = cache_key('user', username)

    adapter.auth(username, password).tap do |value|
      cache_store[user_key(username)] = value if value
    end
  end

  def change_password(username, password)
    raise NoAdapterError unless adapter

    username = sanitize_name(username)
    key = cache_key('user', username)

    adapter.change_password(username, password).tap do |value|
      cache_store[user_key(username)] = value if value
    end
  end

  def lock(_username)
    raise NoAdapterError unless adapter

    raise NotImplementedError
  end

  def unlock(_username)
    raise NoAdapterError unless adapter

    raise NotImplementedError
  end

  def admin?(username)
    read(username)[:admin]
  end

  def state(username)
    read(username)[:state]
  end

  def enabled?(username)
    state(username) == :enabled
  end

  def locked?(username)
    state(username) == :locked
  end

  def disabled?(username)
    state(username) == :enabled
  end

  def list
    raise NoAdapterError unless adapter

    cache_store.fetch(user_list_key) do
      adapter.list.tap { |value| cache_store[user_list_key] = value }
    end
  end
end
