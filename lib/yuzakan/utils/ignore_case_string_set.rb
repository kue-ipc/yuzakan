# frozen_string_literal: true

# Yuzakan::Utils::IgnoreCaseStringSet
#
# 大文字小文字を無視した文字列のSet
# 要素は全て小文字化し、freezeされる

module Yuzakan
  module Utils
    class IgnoreCaseStringSet
      include Enumerable

      def self.normalize(obj)
        -obj.to_s.downcase
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

      def each(&)
        return to_enum unless block_given?

        @attrs.each(&)
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
