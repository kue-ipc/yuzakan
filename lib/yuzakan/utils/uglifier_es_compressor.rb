# frozen_string_literal

require 'hanami/assets/compressors/uglifier_javascript'
require 'uglifier'

module Yuzakan
  module Utils
    class UglifierEsCompressor < Hanami::Assets::Compressors::UglifierJavascript
      def initialize
        @compressor = Uglifier.new(harmony: true)
      end
    end
  end
end
