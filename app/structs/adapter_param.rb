# frozen_string_literal: true

module Yuzakan
  module Structs
    class AdapterParam < Yuzakan::DB::Struct
      def key
        name.intern
      end

      def pair
        [key, value]
      end
      alias to_a pair
    end
  end
end
