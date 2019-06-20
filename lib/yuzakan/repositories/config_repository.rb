# frozen_string_literal: true

class ConfigRepository < Hanami::Repository
  def initialized?
    !!current
  end

  def current
    @curent_config ||= first
  end
end
