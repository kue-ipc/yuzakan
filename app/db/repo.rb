# frozen_string_literal: true

require "hanami/db/repo"

module Yuzakan
  module DB
    class Repo < Hanami::DB::Repo
      private def generate_like_pattern(str, match: :partial)
        escaped = str.gsub("\\", "\\\\").gsub("_", "\\_").gsub("%", "\\%")
        case match
        in :partial
          "%#{escaped}%"
        in :prefix
          "#{escaped}%"
        in :suffix
          "%#{escaped}"
        in :exact
          escaped
        end
      end
    end
  end
end
