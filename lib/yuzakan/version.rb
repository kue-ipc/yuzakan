# frozen_string_literal: true

module Yuzakan
  module Version
    NAME = "Yuzakan"
    VERSION = "0.7.0-alpha"
    LICENSE = -File.read(Hanami.app_path.dirname.parent / "LICENSE")

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
end
