# frozen_string_literal: true

# Yuzakan::Apadters::Manager
# 各adaptersを遅延読み込みする。

module Yuzakan
  module Adapters
    class Manager
      def initialize
        @adapters = search_adapters(base: :abstract).freeze
      end

      def hash
        @adapters
      end

      def list
        @adapters.keys
      end

      def class_list
        @adapters.values
      end

      def by_name(name)
        @adapters[name]
      end

      def get_name(adapter)
        @adapters.key(adapter)
      end

      private def search_adapters(base: :abstract)
        base_file_basename = "#{base}_adapter"
        require_relative "adapters/#{base_file_basename}"
        base_class_name = camelize(base_file_basename)
        base_class = ::Yuzakan::Adapters.const_get(base_class_name)

        list = {}
        Dir.each_child(File.join(__dir__, 'adapters')).each do |child|
          next unless %w[.rb .so].include?(File.extname(child))

          adapter_file_basename = File.basename(child, '.*')
          next unless adapter_file_basename.end_with?('_adapter')
          next if adapter_file_basename == base_file_basename

          require_relative "adapters/#{adapter_file_basename}"
          adapter_class_name = camelize(adapter_file_basename)
          adapter_class = ::Yuzakan::Adapters.const_get(adapter_class_name)
          if adapter_class < base_class
            adapter_name = adapter_file_basename.sub(/_adapter$/, '')
            list[adapter_name] = adapter_class
          end
        end
        list
      end

      private def camelize(str)
        str.split('_').map { |s| s.capitalize }.join
      end
    end
  end
end
