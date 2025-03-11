# frozen_string_literal: true

module Local
  module Structs
    class LocalGroup < Local::DB::Struct
      def members
        lcoal_users + local_member_users
      end
      alias users members
    end
  end
end
