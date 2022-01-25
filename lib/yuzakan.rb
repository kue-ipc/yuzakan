require_relative 'yuzakan/adapters'
require_relative 'yuzakan/helpers'
require_relative 'yuzakan/suppression'

module Yuzakan
  @@name = -'Yuzakan'   # rubocop:disable Style/ClassVars
  @@version = -'v0.5.1' # rubocop:disable Style/ClassVars

  def self.name
    @@name
  end

  def self.version
    @@version
  end
end
