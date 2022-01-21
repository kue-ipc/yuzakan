require 'hanami/assets/compressors/uglifier_javascript'
require 'uglifier'

module Yuzakan
  module Utils
    class UglifierEsCompressor < Hanami::Assets::Compressors::UglifierJavascript
      def initialize # rubocop:disable Lint/MissingSuper
        @compressor = Uglifier.new(harmony: true)
      end
    end
  end
end
