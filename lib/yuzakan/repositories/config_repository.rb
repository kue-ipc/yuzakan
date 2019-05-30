class ConfigRepository < Hanami::Repository
  def initialized?
    configs.first&.initialized
  end

  def default_role
    raise NotImplementError
  end

  def change_default_role(role)
    raise NotImplementError
  end
end
