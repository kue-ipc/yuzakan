# Require this file for unit tests
ENV['HANAMI_ENV'] ||= 'test'

require_relative '../config/environment'
require 'minitest/autorun'
# minitest/autorun set deprected warning enabled
# so, set no deprectaed warning
Warning[:deprecated] = false

require_relative 'support/db'

Hanami.boot

db_reset
