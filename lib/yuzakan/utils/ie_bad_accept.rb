# frozen_string_literal: true

# IE11が次の条件のときにおかしなHTTP_ACCEPTを送る問題の解決
# * ローカル イントラネット (localhostを除く)
# * HTTPS接続
# この場合は互換モードになり、おかしな接続になる。
# そのため、'text/html'を先頭にし、htmlが常に優先されるようにする。
# なお、IEでJSON接続はないため、考慮しなくてもよい。

module Yuzakan
  module Utils
    class IEBadAccept
      def initialize(app)
        @app = app
      end

      def call(env)
        ie_comp = env['HTTP_USER_AGENT'].include?('MSIE 7.0')
        env['HTTP_ACCEPT'] = 'text/html, ' + env['HTTP_ACCEPT'] if ie_comp
        res = @app.call(env)
        res[1]['X-UA-Compatible'] = 'IE=edge'
        res
      end
    end
  end
end
