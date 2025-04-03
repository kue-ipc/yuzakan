# frozen_string_literal: true

require "rom-factory"
require "faker"
require "i18n"

Factory = ROM::Factory.configure { |config|
  config.rom = Hanami.app["db.rom"]
}

Faker::Config.locale = :ja

Dir["#{__dir__}/factories/*.rb"].each { |file| require file }
