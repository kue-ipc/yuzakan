require_relative 'yuzakan/adapters'
require_relative 'yuzakan/helpers'
require_relative 'yuzakan/suppression'

module Yuzakan
  VERSION = 'v0.5.1'

  def self.version
    Yuzakan::VERSION
  end
end
