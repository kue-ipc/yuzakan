require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class DummyAdapter < AbstractAdapter
      KIND =
        if Hanami.env == 'test'
          :normal
        else
          :hidden
        end

      LABEL = 'Dummy'
    end
  end
end
