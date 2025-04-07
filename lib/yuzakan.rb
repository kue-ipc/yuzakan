# frozen_string_literal: true

require_relative "yuzakan/adapters"
require_relative "yuzakan/helpers"
require_relative "yuzakan/suppression_aaa"
require_relative "yuzakan/monkey_patch"

module Yuzakan
  NAME = "Yuzakan"
  VERSION = "0.7.0-alpha"
  LICENSE = -File.read(File.join(__dir__, "..", "LICENSE"))

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
