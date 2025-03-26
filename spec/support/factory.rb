# frozen_string_literal: true

require "rom-factory"
require "faker"

Factory = ROM::Factory.configure { |config|
  config.rom = Hanami.app["db.rom"]
}

Dir["#{__dir__}/factories/*.rb"].each { |file| require file }
