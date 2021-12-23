require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class DummyAdapter < AbstractAdapter
      LABEL = 'Dummy'

      def self.selectable?
        Hanami.env == 'test'
      end
    end
  end
end
