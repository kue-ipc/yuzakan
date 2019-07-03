# frozen_string_literal: true

class Provider < Hanami::Entity
  def adapter_class
    ADAPTERS.by_name(adapter_name)
  end

  def adapter
    adapter_class.new(params)
  end

  def params(secret: true)
    data = {}
    ProviderRepository.params(secret: secret).each do |param_name|
      params = __send__(param_name)
      if params.nil?
        data = nil
        break
      end

      params.each do |param|
        data[param.name.intern] = param.value
      end
    end
    data
  end
end
