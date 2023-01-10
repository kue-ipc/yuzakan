# frozen_string_literal: true

module Yuzakan
  module Utils
    module HashArray
      def ha_merge(harr, key:, delete_key: :delete)
        data = {}

        harr.each do |hash|
          key_value = hash[key]

          next if key_value.nil?

          if hash[delete_key]
            data.delete(key_value) if data.key?(key_value)
          else
            data[key_value] = (data[key_value] || {}).merge(hash)
          end
        end
        data.values
      end
      module_function :ha_merge
    end
  end
end
