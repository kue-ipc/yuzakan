class ActivityRepository < Hanami::Repository
  associations do
    belongs_to :user
  end

  def by_user_target(username)
    activities.where(type: 'user', target: username)
  end

  def user_auths(username, ago: nil)
    auths = by_user_target(username).where(action: 'auth')
    auths = auths.where { created_at >= Time.now - ago } if ago
    auths.order { created_at.desc }
  end
end
