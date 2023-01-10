# frozen_string_literal: true

class ConfigRepository < Hanami::Repository
  private :create, :update, :delete

  def initialized?
    !current.nil?
  end

  def current
    @current ||= first
  end

  def current_create(params)
    @current = create(params)
  end

  def current_update(params)
    @current = update(current.id, params)
  end
end
