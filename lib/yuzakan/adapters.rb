# frozen_string_literal: true

# require_relative 'adapters/dummy_adapter'
# require_relative 'adapters/local_adapter'
# require_relative 'adapters/ldap_adapter'
# require_relative 'adapters/active_directory_adapter'

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

  #   module_function
  #
  #   def hash
  #     @@adapters ||= list.map do |adapter|
  #       [adapter.name, datater]
  #     end
  #
  #   end
  #
  #   def list
  #     @@list ||= [
  #       Yuzakan::Adapters::DummyAdapter,
  #       Yuzakan::Adapters::LocalAdapter,
  #       Yuzakan::Adapters::LdapAdapter,
  #       Yuzakan::Adapters::ActiveDirectoryAdapter,
  #     ].freeze
  #   end
  #
  #   def get(id)
  #     list[id]
  #   end
  #
  #   def get_by_name(name)
  #     ::Yuzakan::Adapters.const_defined?(name) &&
  #       ::Yuzakan::Adapters.const_get(name)
  #   end
  #
  #   def adapter_of_provider(provider)
  #     @@adapter_cache ||= {}
  #
  #     if @@adapter_cache[provider.name].nil? ||
  #         @@adapter_cache[provider.name][:update_at] != provider.updated_at
  #       # Adapterの再作成
  #
  #       # パラメーターがない場合は取得し直す。
  #       if provider.params.nil?
  #         provider = ProviderRepository.new.find_with_params(provider.id)
  #       end
  #
  #       @@adapter_cache[provider.name] = {
  #         update_at: provider.update_at,
  #         adapter: provider.adapter,
  #       }
  #     end
  #     @@adapter_cache[provider.name][:adapter]
  #   end
  end
end
