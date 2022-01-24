module Yuzakan
  module Utils
    module HashArray
      def ha_merge(*arrs, key: nil, delete_key: :delete)
        key = arrs.first.keys.first if key.nil?

        data = Hash.new do |hash, new_key|
          hash[new_key] = {}
        end
        arrs.each do |arr|
          arr.each do |item|
            key_value = item[key]

            next if key_value.nil?

            if item[delete_key]
              data.delete(key_value)
            else
              data[key_value].merge!(item)
            end
          end
        end
        data.values
      end
      module_function :ha_merge
    end
  end
end
