# frozen_string_literal: true

# HashとArrayに関するユーティリティー

module Yuzakan
  module Utils
    module Object
      def self.deep_freeze(obj)
        obj.each { |v| deep_freeze(v) } if obj.is_a?(Enumerable)
        obj.freeze
      end
    end
  end
end
