# frozen_string_literal: true

require "ipaddr"

module Yuzakan
  module Repos
    class NetworkRepo < Yuzakan::DB::Repo
      private def by_address(address) = networks.by_address(address)

      def get(address)
        by_address(address).one
      end

      def set(address, **)
        by_address(address).changeset(:update, **).map(:touch).commit ||
          networks.changeset(:create, **,
            address: normalize_address(address)).map(:add_timestamps).commit
      end

      def unset(address)
        by_address(address).changeset(:delete).commit
      end

      def all
        networks.to_a
      end

      def count
        networks.count
      end

      def find_include_address(address)
        ip = IPAddr.new(address)
        networks.to_a
          .select { |network| network.include?(ip) }
          .max_by(&:prefix)
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
