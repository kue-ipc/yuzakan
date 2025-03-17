# frozen_string_literal: true

module Yuzakan
  module Structs
    class Network < Yuzakan::DB::Struct
      def include?(addr)
        ip.include?(addr)
      end

      def address
        case [ip.family, ip.prefix]
        in [Socket::AF_INET, 32] | [Socket::AF_INET6, 128]
          ip.to_s
        else
          "#{ip}/#{ip.prefix}"
        end
      end

      def to_s
        address
      end

      def prefix
        ip.prefix
      end
    end
  end
end
