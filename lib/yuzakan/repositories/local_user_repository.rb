# frozen_string_literal: true

class LocalUserRepository < Hanami::Repository
  def by_name(name)
    local_users.where(name: name).first
  end
end
