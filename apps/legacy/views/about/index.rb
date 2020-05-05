module Legacy
  module Views
    module About
      class Index
        include Legacy::View

        # モダンブラザーはscriptタグのmoduleが使用でき、
        # ECMAScript2019以上対応とする。
        # 2020年5月3日現在のサポートされているバージョン
        def supported_browsers
          [
            {
              name: 'Google Chrome',
              url: 'https://www.google.co.jp/intl/ja/chrome/',
              version: '79',
            },
            {
              name: '新Microsoft Edge (Chromium)',
              url: 'https://www.microsoft.com/ja-jp/edge',
              note: '旧Microsoft Edge (EdgeHTML)とは異なります。',
              version: '79',
            },
            {
              name: 'Mozilla Firefox',
              url: 'https://www.mozilla.org/ja/firefox/',
              version: '68',
            },
            {
              name: 'Mozilla Firefox ESR',
              url: 'https://www.mozilla.jp/business/',
              version: '68',
            },
            {
              name: 'Apple Safari',
              url: 'https://www.apple.com/jp/safari/',
              version: '13',
            },
            {
              name: 'Opera',
              url: 'https://www.opera.com/ja',
              version: '66',
              # version 66 based on chromium 79
            },
          ]
        end

        def unsupported_browsers
          [
            '旧Microsoft Edge (EdgeHTML)',
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
