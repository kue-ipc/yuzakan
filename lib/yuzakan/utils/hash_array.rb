module Yuzakan
  module Utils
    module HashArray
      def ha_merge(*harr, key: nil, delete_key: :delete)
        key = harr.first.keys.first if key.nil?

        data = Hash.new do |hash, new_key|
          hash[new_key] = {}
        end

        harr.each do |hash|
          key_value = hash[key]

          next if key_value.nil?

          if hash[delete_key]
            data.delete(key_value)
          else
            data[key_value].merge!(hash)
          end
        end
        data.values
      end
      module_function :ha_merge
    end
  end
end
