# frozen_string_literal: true

class Provider < Hanami::Entity
  def adapter
    Yuzakan::Adapters.get_by_name(adapter_name)
  end

  def params
    data = {}
    ProviderRepository.params.each do |param_name|
      __send__(param_name).each do |param|
        data[param.name.intern] = param.value
      end
    end
    data
  end
end
