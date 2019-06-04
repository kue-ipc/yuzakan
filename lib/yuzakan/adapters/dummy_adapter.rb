# frozen_string_literal: true

require_relative 'base_adapter'

module Yuzakan
  module Adapters
    class DummyAdapter < BaseAdapter
      def self.name
        'ダミー'
      end
    end
  end
end
