# frozen_string_literal: true

# User clearance level
# 5: supervisor
# 4: administrator
# 3: operator
# 2: monitor
# 1: user
# 0: guest

module Yuzakan
  module Structs
    class User < Yuzakan::DB::Struct
      def label
        display_name || name
      end

      def deleted?
        deleted
      end

      def prohibited?
        prohibited
      end

      def to_s
        name
      end

      def primary_group
        group
      end

      def supplementary_groups
        member_groups
      end

      def groups
        [group, *member_groups].compact.uniq
      end
    end
  end
end
