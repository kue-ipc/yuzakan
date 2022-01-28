# = IE11互換表示対応
# IE11が次の条件のときにおかしなAcceptを送る問題の対応
# * ローカル イントラネット (localhostを除く)
# * HTTPS接続
# この場合は互換モードになり、'text/html'が含まれない。
# そのため、'text/html'を先頭にし、htmlが常に優先されるようにする。
# IEはそもそも未対応であるため、JSON接続は考慮しない。
# == IE11 互換表示(イントラネット)
# Accept: image/gif, image/jpeg, image/pjpeg, application/x-ms-application, application/xaml+xml, application/x-ms-xbap, */*
# Accept-Encoding: gzip, deflate
# Accept-Language: ja
# User-Agent: Mozilla/4.0 (MSIE 7.0; Trident/7.0; ...)
# == IE11 通常
# Accept: text/html, application/xhtml+xml, image/jxr, */*
# Accept-Encoding: gzip, deflate
# Accept-Language: ja
# User-Agent: Mozilla/5.0 (Trident/7.0; ...) like Gecko

module Yuzakan
  module Middlewares
    class IeCorrector
      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless env['HTTP_USER_AGENT'].include?('Trident')

        env['HTTP_ACCEPT'] = "text/html, #{env['HTTP_ACCEPT']}"
        res = @app.call(env)
        res[1]['X-UA-Compatible'] = 'IE=edge'
        res
      end
    end
  end
end
