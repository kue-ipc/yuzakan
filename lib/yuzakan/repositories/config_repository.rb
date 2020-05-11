# frozen_string_literal: true

class ConfigRepository < Hanami::Repository
  private :create, :update, :delete

  def initialized?
    !current.nil?
  end

  def current
    @@curent ||= first
  end

  def current_create(params)
    @@curent = create(params)
  end

  def current_update(params)
    @@curent = update(current.id, params)
  end
end
