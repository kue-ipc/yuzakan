class LocalUserRepository < Hanami::Repository
  def by_name(name)
    local_users.where(name: name)
  end

  def find_by_name(name)
    by_name(name).first
  end

  def create_with_password(data)
    hashed_password = LocalUser.create_hashed_password(data[:password])
    create(data.merge(hashed_password: hashed_password))
  end

  def lock(id)
    user = find(id)
    return if user.nil?
    return if user.locked?

    update(id, hashed_password: LocalUser.lock_password(user.hashed_password))
  end

  def unlock(id)
    user = find(id)
    return if user.nil?
    return unless user.locked?

    update(id, hashed_password: LocalUser.unlock(user.hashed_password))
  end

  def change_password(id, password)
    user = find(id)
    return if user.nil?

    hashed_password = LocalUser.create_hashed_password(password)
    hashed_password = LocalUser.lock_password(hashed_password) if user.locked?

    update(id, hashed_password: hashed_password)
  end
end
