# frozen_string_literal: true

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class DummyAdapter < AbstractAdapter
      def self.label
        'ダミー'
      end
    end
  end
end
