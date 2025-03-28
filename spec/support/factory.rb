# frozen_string_literal: true

require "rom-factory"
require "faker"
require "i18n"

Factory = ROM::Factory.configure { |config|
  config.rom = Hanami.app["db.rom"]
}

Faker::Config.locale = :ja
# NOTE: Fackerが内部でI18n.with_locale(:en)を使用しているため、localeを設定して
#       おかないと:enになってしまう。
I18n.locale = :ja

Dir["#{__dir__}/factories/*.rb"].each { |file| require file }
