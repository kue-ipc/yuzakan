# メッセージ抑止
# 2.7系におけるobsoleteやdeprecatedを抑止する。
# ライブラリが対応した後はこの部分は削除する。

# URI.escape is obslete
# hanami-router 2系 で対応予定
require 'uri'
module URI
  module Escape
    def escape(*arg)
      # warn "URI.escape is obsolete", uplevel: 1
      DEFAULT_PARSER.escape(*arg)
    end

    def unescape(*arg)
      # warn "URI.unescape is obsolete", uplevel: 1
      DEFAULT_PARSER.unescape(*arg)
    end
  end
end
