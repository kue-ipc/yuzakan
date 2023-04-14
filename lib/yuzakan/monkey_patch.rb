# frozen_string_literal: true

# 個別修正

# ネストされたアセットで拡張子が残る問題の修正
require 'hanami/assets/compiler'
module Hanami
  module Assets
    class Compiler
      # https://github.com/hanami/assets/issues/114
      # ネストされたパスの場合、パス内に'/'があるため、拡張子の除去に失敗する。
      # @since 1.3.0
      # @api private
      private def destination_name
        result = destination_path

        if compile?
          result.scan(%r{\A[[[:alnum:]][-_/]]*\.\w*}).first || result
        else
          result
        end
      end
    end
  end
end
