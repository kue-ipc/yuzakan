require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class DummyAdapter < AbstractAdapter
      self.hidden_adapter = true if Hanami.env != 'test'

      self.label = 'ダミー'

      self.params = []
    end
  end
end
