require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class DummyAdapter < AbstractAdapter
      if Hanami.env != 'test'
        self.hidden_adapter = true
      end

      LABEL = 'Dummy'
    end
  end
end
