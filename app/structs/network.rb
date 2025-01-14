# frozen_string_literal: true

require "ipaddr"

module Yuzakan
  module Structs
    class Network < Yuzakan::DB::Struct
      attr_reader :ipaddr

      def initialize(attributes = nil)
        return super if attributes.nil? # rubocop:disable Lint/ReturnInVoidContext

        @ipaddr = IPAddr.new(attributes[:address])
        super
      end

      def include?(addr)
        @ipaddr.include?(addr)
      end

      def to_s
        prefix = @ipaddr.prefix
        if (prefix == 32 && @ipaddr.ipv4?) ||
            (prefix == 128 && @ipaddr.ipv6?)
          @ipaddr.to_s
        else
          "#{@ipaddr}/#{@ipaddr.prefix}"
        end
      end
    end
  end
end
