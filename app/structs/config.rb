# frozen_string_literal: true

module Yuzakan
  module Structs
    class Config < Yuzakan::DB::Struct
      def password_extra_dict_listing
        password_extra_dict.join(" ")
      end
    end
  end
end
