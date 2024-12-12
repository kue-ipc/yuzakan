# frozen_string_literal: true

module Yuzakan
  module Relations
    class LocalUsers < Yuzakan::DB::Relation
      schema :local_users, infer: true
    end
  end
end
