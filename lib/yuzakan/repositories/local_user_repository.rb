# frozen_string_literal: true

class LocalUserRepository < Hanami::Repository
  def by_username(username)
    local_users.where(username: username)
  end

  def find_by_username(username)
    by_username(username).first
  end

  def ilike(pattern)
    local_users.where { username.ilike(pattern) | display_name.ilike(pattern) | email.ilike(pattern) }
  end
end
