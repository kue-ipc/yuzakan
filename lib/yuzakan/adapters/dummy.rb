# frozen_string_literal: true

module Yuzakan
  module Adapters
    class Dummy < Yuzakan::Adapter
      version "0.1.0"
      hidden Hanami.env?(:production)

      json do
      end
    end
  end
end
