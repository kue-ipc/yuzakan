# frozen_string_literal: true

# Yuzakan::Apadters::Manager
# 各adaptersを遅延読み込みする。

module Yuzakan
  module Adapters
    class Manager
      def initialize
        @adapters = {}
        search_adapters(File.expand_path('adapters', __dir__))
        search_adapters(File.expand_path('../../vendor/adapters', __dir__))
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

      private def search_adapters(adapters_dir)
        Dir.each_child(adapters_dir).each do |child|
          next unless child.end_with?('_adapter.rb', '_adapter.so')

          adapter_file_basename = File.basename(child, '.*')

          require File.join(adapters_dir, child)

          adapter_class_name = camelize(adapter_file_basename)
          adapter_class = ::Yuzakan::Adapters.const_get(adapter_class_name)
          @adapters[adapter_class.name] = adapter_class unless adapter_class.abstract?
        end
        @adapters
      end

      private def camelize(str)
        str.split('_').map(&:capitalize).join
      end
    end
  end
end
