class Provider < Hanami::Entity
  attr_reader :params, :adapter, :adapter_class

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

  def list
    raise 'No adapter' unless adapter

    key = cache_key('list')
    Provider.cache.read(key)&.tap { |value| return value }

    value = adapter.list
    Provider.cache.write(key, value)
    value
  end
end
