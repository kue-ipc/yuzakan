# frozen_string_literal: true

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class DummyAdapter < AbstractAdapter
      def self.label
        'ダミー'
      end

      def self.selectable?
        Hanami.env == 'test'
      end

      self.params = []
    end
  end
end
