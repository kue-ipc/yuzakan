# IE11が次の条件のときにおかしなHTTP_ACCEPTを送る問題の解決
# * ローカル イントラネット (localhostを除く)
# * HTTPS接続
# この場合は互換モードになり、おかしな接続になる。
# そのため、'text/html'を先頭にし、htmlが常に優先されるようにする。
# なお、IEでJSON接続はないため、考慮しなくてもよい。

module Yuzakan
  module Middlewares
    class IeCorrector
      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless env['HTTP_USER_AGENT'].include?('Trident')

        env['HTTP_ACCEPT'] = 'text/html, ' + env['HTTP_ACCEPT']
        res = @app.call(env)
        res[1]['X-UA-Compatible'] = 'IE=edge'
        res
      end
    end
  end
end
