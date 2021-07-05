class Provider < Hanami::Entity
  attr_reader :params, :adapter, :adapter_class

  USERNAME_RE = /\A[\w.-]+\z/.freeze

  class NoAdapterError < StandardError
    def initialize(msg = 'No adapter, but need an adapter.')
      super
    end
  end

  def self.cache
    @cache ||= Readthis::Cache.new(
      expires_in: 60 * 60,
      redis: {url: 'redis://127.0.0.1:6379/0'})
  end

  def initialize(attributes = nil)
    unless attributes
      super
      return
    end

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

  def cache_key(action, param = nil)
    ['yuzakan', 'provider', name, action, param].join(':')
  end

  def cache_clear
    cache.delete_matched(cache_key('*'))
  end

  def sanitize_name
    raise ArgumentError, 'username is not uesr' unless username =~ /\A\w+\z/
    username.downcase(:ascii)
  end

  def check
    raise NoAdapterError unless adapter

    adapter.check
  end

  def create(username, attrs)
    raise NoAdapterError unless adapter

    adapter.create(username, attrs, attr_mappings)
  end

  def read(username)
    raise NoAdapterError unless adapter

    key = cache_key('read', username)
    Provider.cache.fetch(key) do
      adapter.read(username, attr_mappings).tap do |value|
        Provider.cache.write(key, value)
      end
    end
  end

  def udpate(_username, _attrs, mappings = nil)
    raise NoAdapterError unless adapter

    raise NotImplementedError
  end

  def delete(_username)
    raise NoAdapterError unless adapter

    raise NotImplementedError
  end

  def auth(_username, _password)
    raise NoAdapterError unless adapter

    raise NotImplementedError
  end

  def change_password(_username, _password)
    raise NoAdapterError unless adapter

    raise NotImplementedError
  end

  def lock(_username)
    raise NoAdapterError unless adapter

    raise NotImplementedError
  end

  def unlock(_username)
    raise NoAdapterError unless adapter

    raise NotImplementedError
  end

  def locked?(_username)
    raise NoAdapterError unless adapter

    raise NotImplementedError
  end

  def list
    raise NoAdapterError unless adapter

    key = cache_key('list')
    Provider.cache.fetch(key) do
      adapter.list.tap { |value| Provider.cache.write(key, value) }
    end
  end
end
