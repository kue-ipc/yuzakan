# frozen_string_literal: true

module Yuzakan
  module Repos
    class AuthLogRepo < Yuzakan::DB::Repo
      def recent(user, type: :auth, period: nil, limit: 0, includes: nil, excludes: nil)
        period = Time.now - period if period.is_a?(Numeric)

        logs = auth_logs.by_user(user)
        logs = logs.where(type: type.to_s) if type
        logs = logs.where { created_at >= period } if period
        logs = logs.where(result: includes) if includes
        logs = logs.exclude(result: excludes) if excludes
        logs = logs.limit(limit) if limit.positive?
        logs.order { created_at.desc }
      end
    end
  end
end
