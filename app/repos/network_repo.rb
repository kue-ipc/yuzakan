# frozen_string_literal: true

require "ipaddr"

module Yuzakan
  module Repos
    class NetworkRepo < Yuzakan::DB::Repo
      # compatible interfaces
      commands :create, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:created_at, :updated_at]}}
      commands update: :by_pk, use: :timestamps,
        plugins_options: {timestamps: {timestamps: [:updated_at]}}
      commands delete: :by_pk
      def all = networks.to_a
      def find(id) = networks.by_pk(id).one
      def first = networks.first
      def last = networks.last
      def clear = networks.delete

      def find_include(addr)
        return if addr.nil?

        addr = IPAddr.new(addr) unless addr.is_a?(IPAddr)

        networks.where { Sequel.lit("ip >>= ?", addr.to_s) }
          .order { masklen(ip) }.last
      end
    end
  end
end
