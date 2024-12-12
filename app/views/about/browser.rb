# frozen_string_literal: true

module Yuzakan
  module Views
    module Home
      class Browser < Yuzakan::View
        def supported_browsers
          [
            {
              name: "Google Chrome",
              url: "https://www.google.co.jp/intl/ja/chrome/",
              admin: true,
            },
            {
              name: "Microsoft Edge",
              url: "https://www.microsoft.com/ja-jp/edge",
              admin: true,
            },
            {
              name: "Mozilla Firefox",
              url: "https://www.mozilla.org/ja/firefox/",
            },
            {
              name: "Mozilla Firefox ESR",
              url: "https://www.mozilla.jp/business/",
            },
            {
              name: "Apple Safari",
              url: "https://www.apple.com/jp/safari/",
            },
            {
              name: "Opera",
              url: "https://www.opera.com/ja",
            },
          ]
        end

        def unsupported_browsers
          [
            "Microsoft Internet Explorer",
            "Opera以外のOpera製ブラウザー(Opera Mini等)",
            "エンジン選択型ブラウザー(Sleipnir、Lunascape等)",
            "Linuxデスクトップ環境ブラウザー(Konqueror、GNOME Web等)",
            "アプリ内ブラウザー",
            "ガラケー搭載のブラウザー",
            "ガラホ搭載のブラウザー",
            "テキストベースのブラウザー (Lynx、w3m等)",
            "サポートが終了したブラウザー",
          ]
        end
      end
    end
  end
end
