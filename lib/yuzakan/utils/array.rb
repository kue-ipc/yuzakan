# frozen_string_literal: true

module Yuzakan
  module Utils
    module Array
      def self.deep_map(array, &block)
        array.map do |item|
          if item.is_a?(::Array)
            deep_map(item, &block)
          else
            block.call(item)
          end
        end
      end
    end
  end
end
