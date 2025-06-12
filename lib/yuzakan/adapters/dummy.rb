# frozen_string_literal: true

module Yuzakan
  module Adapters
    class Dummy < Yuzakan::Adapter
      self.name = "dummy"
      self.display_name = "ダミー"
      self.version = "0.0.1"
      self.params = [].freeze

      hidden Hanami.env?(:production)
    end
  end
end
