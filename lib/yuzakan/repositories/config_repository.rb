# frozen_string_literal: true

class ConfigRepository < Hanami::Repository
  def initialized?
    !!current
  end

  def current
    first
  end
end
