# frozen_string_literal: true

module Yuzakan
  module Relations
    class ActivityLogs < Yuzakan::DB::Relation
      schema :activity_logs, infer: true
    end
  end
end
