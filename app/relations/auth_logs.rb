# frozen_string_literal: true

module Yuzakan
  module Relations
    class AuthLogs < Yuzakan::DB::Relation
      schema :auth_logs, infer: true
    end
  end
end
