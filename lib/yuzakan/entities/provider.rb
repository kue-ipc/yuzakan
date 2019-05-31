# frozen_string_literal: true

class Provider < Hanami::Entity
  def adapter
    Yuzakan::Adapters::LIST[adapter_id]
  end

  def params
    data = {}
    ProviderRepository.params.each do |param_name|
      __send__(param_name).each do |param|
        data[param.name] = param.value
      end
    end
    data
  end
end
