# frozen_string_literal: true

module Yuzakan
  module Relations
    class ActionLogs < Yuzakan::DB::Relation
      schema :action_logs, infer: true
    end
  end
end
