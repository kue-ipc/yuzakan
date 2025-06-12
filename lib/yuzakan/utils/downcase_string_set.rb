# frozen_string_literal: true

# Yuzakan::Utils::DowncaseStringSet
# 要素を全て文字列化、小文字化、フリーズさせるSet

module Yuzakan
  module Utils
    class DowncaseStringSet
      include Enumerable

      def initialize(enum = nil)
        @set = Set.new
        return if enum.nil?

        enum.each do |obj|
          obj = yield obj if block_given?
          @set << normalize(obj)
        end
      end

      def each(&)
        return to_enum unless block_given?

        @set.each(&)
      end

      def dup
        self.class.new(self)
      end

      def union(enum)
        dup.merge(enum)
      end
      alias + union
      alias | union

      def add(obj)
        @set.add(normalize(obj))
      end
      alias << add

      def include?(obj)
        @set.include?(normalize(obj))
      end
      alias member? include?
      alias === include?

      def merge(enum)
        enum.each { |obj| add(obj) }
      end

      private def normalize(obj)
        -obj.to_s.downcase
      end
    end
  end
end
