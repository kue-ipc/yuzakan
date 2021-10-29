module Web
  module Views
    module About
      class Browser
        include Web::View
        layout :about

        # モダンブラザーはscriptタグのmoduleが使用でき、
        # ECMAScript2019以上対応とする。
        # 2021年後期のサポートされているバージョン
        def supported_browsers
          [
            {
              name: 'Google Chrome',
              url: 'https://www.google.co.jp/intl/ja/chrome/',
              version: '94',
            },
            {
              name: 'Microsoft Edge',
              url: 'https://www.microsoft.com/ja-jp/edge',
              version: '74',
            },
            {
              name: 'Mozilla Firefox',
              url: 'https://www.mozilla.org/ja/firefox/',
              version: '91',
            },
            {
              name: 'Mozilla Firefox ESR',
              url: 'https://www.mozilla.jp/business/',
              version: '91',
            },
            {
              name: 'Apple Safari',
              url: 'https://www.apple.com/jp/safari/',
              version: '14',
            },
            {
              name: 'Opera',
              url: 'https://www.opera.com/ja',
              version: '80',
              # version 80 based on chromium 94
            },
          ]
        end

        def unsupported_browsers
          [
            'Microsoft Internet Explorer',
            'Opera以外のOpera製ブラウザー',
            'エンジン選択型ブラウザー(Sleipnir、Lunascape等)',
            'Linuxデスクトップ環境ブラウザー(Konqueror、GNOME Web等)',
            'アプリ内ブラウザー',
            'ガラケー搭載のブラウザー',
            'ガラホ搭載のブラウザー',
            'テキストベースのブラウザー (Lynx、w3m等)',
            'サポートが終了したブラウザー',
          ]
        end
      end
    end
  end
end
