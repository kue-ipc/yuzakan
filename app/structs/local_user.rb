# frozen_string_literal: true

module Yuzakan
  module Structs
    class LocalUser < Yuzakan::DB::Struct
      def locked?
        locked
      end
    end
  end
end
