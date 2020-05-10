# frozen_string_literal: true

class ConfigRepository < Hanami::Repository
  private :create, :update, :delete

  def initialized?
    !!current
  end

  def current
    @@curent_config ||= first
  end

  def current_create(params)
    @@curent_config = create(params)
  end

  def current_update(params)
    @@curent_config = update(current.id, params)
  end
end
