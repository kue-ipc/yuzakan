# frozen_string_literal: true

require "ipaddr"

module Yuzakan
  module Repos
    class NetworkRepo < Yuzakan::DB::Repo
      def get(address)
        address = normalize_address(address)
        networks.by_address(address).one
      end

      def set(address, **)
        address = normalize_address(address)
        networks.by_address(address).changeset(:update,
                                               **).map(:touch).commit ||
          networks.changeset(:create, **,
            address: address).map(:add_timestamps).commit
      end

      def unset(address)
        address = normalize_address(address)
        networks.by_address(address).changeset(:delete).commit
      end

      def all
        networks.to_a
      end

      def count
        networks.count
      end

      private def normalize_address(address)
        ipaddr = IPAddr.new(address)
        prefix = ipaddr.prefix
        if (prefix == 32 && ipaddr.ipv4?) ||
           (prefix == 128 && ipaddr.ipv6?)
          ipaddr.to_s
        else
          "#{ipaddr}/#{ipaddr.prefix}"
        end
      end
    end
  end
end
