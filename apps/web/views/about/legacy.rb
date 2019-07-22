# frozen_string_literal: true

module Web
  module Views
    module About
      class Legacy
        include Web::View
        layout false

        # 2019年7月22日現在でサポート済みブラウザのみ

        def supported_browsers
          [
            {
              name: 'Google Chrome',
              url: 'https://www.google.co.jp/intl/ja/chrome/',
              version: '67',
            },
            {
              name: 'Chromium版Microsoft Edge',
              url: 'https://www.microsoftedgeinsider.com/ja-jp/',
              version: '75',
              note: '現在プレビュー版です。Windows 10 1903以下に付属したEdgeHTML版Microsoft Edgeとは異なります。',
            },
            {
              name: 'Mozilla Firefox',
              url: 'https://www.mozilla.org/ja/firefox/',
              version: '60',
              note: 'ESR版含みます。',
            },
            {
              name: 'Apple Safari',
              url: 'https://www.apple.com/jp/safari/',
              version: '11.1',
            },
            {
              name: 'Opera',
              url: 'https://www.opera.com/ja',
              version: '54',
              note: 'Opera Touchについては未確認です。',
            },
          ]
        end

        def unsupported_browsers
          [
            'EdgeHTML版Microsoft Edge',
            'Microsoft Internet Explorer',
            'Opera mini',
            'アプリ内ブラウザー',
            'ガラケー搭載ブラウザー',
            'ガラホ搭載ブラウザー',
            'サポートが終了したブラウザー',
          ]
        end

      end
    end
  end
end
