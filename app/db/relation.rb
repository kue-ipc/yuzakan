# frozen_string_literal: true

require "hanami/db/relation"

module Yuzakan
  module DB
    class Relation < Hanami::DB::Relation
      DEFAULT_PER_PAGE = 20
    end
  end
end
