# frozen_string_literal: true

module Yuzakan
  module Structs
    class Group < Yuzakan::DB::Struct
      def label
        display_name || name
      end

      def to_s
        name
      end

      def deleted?
        deleted
      end
    end
  end
end
