# frozen_string_literal: true

class AuthLogRepository < Hanami::Repository
  def by_username(username)
    auth_logs.where(username: username)
  end

  def recent_by_username(username, ago)
    by_username(username)
      .where(result: ["success", "failure", "recover"])
      .where { created_at >= Time.now - ago }
      .order { created_at.desc }
  end
end
