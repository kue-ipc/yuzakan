# frozen_string_literal: true

require 'set'

module Yuzakan
  module Utils
    class IgnoreCaseStringSet
      include Enumerable

      def self.normalize(obj)
        obj.to_s.downcase.freeze
      end

      def initialize(enum = nil)
        @attrs = Set.new
        return if enum.nil?

        enum.each do |obj|
          obj = yield obj if block_given?
          @attrs << IgnoreCaseStringSet.normalize(obj)
        end
      end

      def union(enum)
        IgnoreCaseStringSet.new(self).merge(enum)
      end
      alias + union
      alias | union

      def each(&block)
        return to_enum unless block_given?

        @attrs.each(&block)
      end

      def add(obj)
        @attrs.add(IgnoreCaseStringSet.normalize(obj))
      end
      alias << add

      def include?(obj)
        @attrs.include?(IgnoreCaseStringSet.normalize(obj))
      end
      alias member? include?
      alias === include?

      def merge(enum)
        enum.each do |obj|
          @attrs << IgnoreCaseStringSet.normalize(obj)
        end
      end
    end
  end
end
