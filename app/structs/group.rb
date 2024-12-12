# frozen_string_literal: true

module Yuzakan
  module Structs
    class Group < Yuzakan::DB::Struct
      def label_name
        if display_name
          "#{display_name} (#{name})"
        else
          name
        end
      end

      def label
        display_name || name
      end

      def to_s
        name
      end
    end
  end
end
