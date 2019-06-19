# frozen_string_literal: true

class Provider < Hanami::Entity
  def adapter
    Yuzakan::Adapters.get_by_name(adapter_name)
  end

  def params
    data = {}
    ProviderRepository.params.each do |param_name|
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
