# frozen_string_literal: true

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class DummyAdapter < AbstractAdapter
      self.name = 'dummy'
      self.display_name = 'ダミー'
      self.version = '0.0.1'
      self.params = []

      hidden true if Hanami.env == 'production'
    end
  end
end
