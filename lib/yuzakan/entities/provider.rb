class Provider < Hanami::Entity
  attr_reader :params, :adapter, :adapter_class

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
end
