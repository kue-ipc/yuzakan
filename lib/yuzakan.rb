require_relative 'yuzakan/adapters'
require_relative 'yuzakan/helpers'
require_relative 'yuzakan/suppression'

module Yuzakan
  NAME = 'Yuzakan'
  VERSION = 'v0.5.1'

  def self.name
    Yuzakan::NAME
  end

  def self.version
    Yuzakan::VERSION
  end
end
