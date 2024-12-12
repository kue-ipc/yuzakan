# frozen_string_literal: true

module Yuzakan
  module Relations
    class Configs < Yuzakan::DB::Relation
      schema :configs, infer: true
    end
  end
end
