# frozen_string_literal: true

require 'hanami/assets/compressors/javascript'
require 'terser'

module Yuzakan
  module Utils
    class TerserCompressor < Hanami::Assets::Compressors::Javascript
      def initialize # rubocop:disable Lint/MissingSuper
        @compressor = Terser.new
      end
    end
  end
end
