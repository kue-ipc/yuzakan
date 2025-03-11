# frozen_string_literal: true

module Local
  module Structs
    class LocalUser < Local::DB::Struct
      def locked?
        locked
      end

      def primary_group
        local_group
      end

      def groups
        local_member_groups
      end
    end
  end
end
