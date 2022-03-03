# Require this file for unit tests
ENV['HANAMI_ENV'] ||= 'test'

require_relative '../config/environment'
require 'minitest/autorun'
# minitest/autorun set deprected warning enabled
# so, set no deprectaed warning
Warning[:deprecated] = false

require 'rr'
extend RR # rubocop:disable Style/MixinUsage

require_relative 'support/db'
require_relative 'support/mock'

Hanami.boot
