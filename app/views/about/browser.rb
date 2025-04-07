# frozen_string_literal: true

module Yuzakan
  module Views
    module About
      class Browser < Yuzakan::View
        expose :supported_browsers, decorate: false do
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
            # {
            #   name: "Pale Moon",
            #   url: "https://www.palemoon.org/",
            # },
          ]
        end

        expose :unsupported_browsers, decorate: false do
          [
            "Microsoft Internet Explorer",
            "Opera以外のOpera製ブラウザー(Opera Mini等)",
            "エンジン選択型ブラウザー(Sleipnir、Lunascape等)",
            "Linuxデスクトップ環境ブラウザー(Konqueror、GNOME Web等)",
            "アプリ内ブラウザー",
            "フィーチャーホン搭載のブラウザー",
            "テキストベースのブラウザー (Lynx、w3m等)",
            "メンテナンス期間が終了したブラウザー(サポートしているブラウザーの古いバージョン含む)",
            "メンテナンス期間が終了したOS上のブラウザー",
          ]
        end
      end
    end
  end
end
