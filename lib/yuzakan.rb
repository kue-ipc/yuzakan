# frozen_string_literal: true

require_relative 'yuzakan/adapters'
require_relative 'yuzakan/helpers'
require_relative 'yuzakan/suppression'

module Yuzakan
  NAME = 'Yuzakan'
  VERSION = '0.6.0'
  LICENSE = -File.read(File.join(__dir__, '..', 'LICENSE'))

  def self.name
    NAME
  end

  def self.version
    VERSION
  end

  def self.license
    LICENSE
  end
end
