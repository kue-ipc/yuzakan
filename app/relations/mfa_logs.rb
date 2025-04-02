# frozen_string_literal: true

module Yuzakan
  module Relations
    class MfaLogs < Yuzakan::DB::Relation
      schema :mfa_logs, infer: true
    end
  end
end
