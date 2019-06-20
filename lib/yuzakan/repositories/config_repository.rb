# frozen_string_literal: true

class ConfigRepository < Hanami::Repository
  def initialized?
    !!current
  end

  def current
    @@curent_config ||= first
  end

  def cache_clear
    @@curent_config = nil
  end

  def setup(data)
    if current
      update(@@curent_config.id, data)
      cache_clear
    else
      create(data)
    end
  end

end
