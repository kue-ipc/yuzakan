# frozen_string_literal: true

require "ipaddr"

module Yuzakan
  module Repos
    class NetworkRepo < Yuzakan::DB::Repo
      private def by_ip(ip) = networks.by_ip(ip)

      def get(ip)
        return get(IPAddr.new(ip)) if ip.is_a?(String)

        by_ip(ip).one
      end

      def set(ip, **)
        return set(IPAddr.new(ip), **) if ip.is_a?(String)

        by_ip(ip).changeset(:update, **).map(:touch).commit ||
          networks.changeset(:create, **, ip: ip).map(:add_timestamps).commit
      end

      def unset(ip)
        return unset(IPAddr.new(ip)) if ip.is_a?(String)

        by_ip(ip).changeset(:delete).commit
      end

      def all
        networks.to_a
      end

      def count
        networks.count
      end

      def find_include(addr)
        return if addr.nil?
        return find_include(IPAddr.new(addr)) if addr.is_a?(String)

        networks.where { Sequel.lit("ip >>= ?", addr.to_s) }
          .order { masklen(ip) }.last
      end
    end
  end
end
