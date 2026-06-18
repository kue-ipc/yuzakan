# frozen_string_literal: true

require "ipaddr"

module Yuzakan
  module Repos
    class NetworkRepo < Yuzakan::DB::Repo
      def find_include(addr)
        return if addr.nil?

        addr = IPAddr.new(addr) unless addr.is_a?(IPAddr)

        networks.where { Sequel.lit("ip >>= ?", addr.to_s) }.order { masklen(ip) }.last
      end
    end
  end
end
