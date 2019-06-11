# frozen_string_literal: true

class ConfigRepository < Hanami::Repository
  def initialized?
    !!current&.initialized
  end

  def current
    first
  end
end
