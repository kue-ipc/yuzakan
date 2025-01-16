# frozen_string_literal: true

require "hanami/db/repo"

module Yuzakan
  module DB
    class Repo < Hanami::DB::Repo
      private def normalize_name(name)
        name.to_s.downcase
      end
    end
  end
end
