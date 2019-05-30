# frozen_string_literal: true

class Provider < Hanami::Entity
  ADAPTERS = [
    DummyAdapter,
    LocalAdapter,
  ]

  def initilaize(attributes = {})
    super
    @adapter = ADAPTERS[adapter_id].new(Provider)
  end


  def auth(name, password)
  end
end
