# frozen_string_literal: true

# change compressor from uglifier to terser

require 'hanami/assets/compressors/uglifier_javascript'
# require 'uglifier'
require 'terser'

require_relative '../../yuzakan'

module Yuzakan
  module Utils
    class UglifierEsCompressor < Hanami::Assets::Compressors::UglifierJavascript
      def initialize # rubocop:disable Lint/MissingSuper
        # @compressor = Uglifier.new(harmony: true)
        @compressor = Terser.new
      end

      def read(filename)
        modify(super)
      end

      def modify(data)
        data = data.dup
        [
          /(\b(?:im|ex)port\b[\s\w,*{}]*\bfrom\b\s*)"([^"]*)"/,
          /(?<!")(\bimport\b\s*)"([^"]*)"/,
          /(\bimport\b\s*\(\s*)"([^"]*)"(\s*\))/,
        ].each do |re|
          data.gsub!(re, "\\1\"\\2?v=#{Yuzakan.version}\"\\3")
          data.gsub!(Regexp.compile(re.source.tr('"', "'")), "\\1'\\2?v=#{Yuzakan.version}'\\3")
        end
        data
      end
    end
  end
end
