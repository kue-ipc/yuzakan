require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class DummyAdapter < AbstractAdapter
      self.hidden_adapter = true if Hanami.env == 'production'

      self.name = 'dummy'
      self.label = 'ダミー'
      self.version = '0.0.1'
      self.params = []
    end
  end
end
