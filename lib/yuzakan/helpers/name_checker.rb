module Yuzakan
  module Helpers
    module NameChecker
      ID_RE = /\A(?:0|[1-9]\d*)\z/.freeze
      NAME_RE = /\A[a-z_](?:\.?[a-z0-9_-])*\z/.freeze

      private def nomarlize_name(str)
        str = str.downcase
        case check_type(str)
        when :id
          str.to_i
        when :name
          str
        end
      end

      private def check_type(str)
        case str
        when ID_RE
          :id
        when NAME_RE
          :name
        end
      end

      private def name?(str)
        check_type(str) == :name
      end

      private def id?(str)
        check_type(str) == :id
      end
    end
  end
end
