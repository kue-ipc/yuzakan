# frozen_string_literal: true

class Provider < Hanami::Entity
  def adapter_class
    ADAPTERS.by_name(adapter_name)
  end

  def adapter
    adapter_class.new(params)
  end

  def params
    {}.tap do |data|
      ProviderRepository.params.each do |param_name|
        params = __send__(param_name)
        next if params.nil?

        params.each do |param|
          data[param.name.intern] = param.value
        end
      end
    end
  end
end
