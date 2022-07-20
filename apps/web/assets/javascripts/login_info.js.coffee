import {app, text} from './hyperapp.js'
import * as html from './hyperapp-html.js'

import {DL_CLASSES, DT_CLASSES, DD_CLASSES} from './dl_horizontal.js'

loginInof = () ->
  html.div {}, [
    html.h3 {}, text 'アカウント ログイン情報 通知書'
    html.div {class: 'row.my-3'}
    .
      div class=col_name
        | アカウント名:
      div class=col_value
        code.login-info
          = user.name

    .row.my-3
      div class=col_name
        | 初回パスワード:
      div class=col_value
        code.login-info
          = password

    .row.my-3
      div class=col_name
        | アカウント管理サイト:
      div class=col_value
        = link_to Web.routes.url(:root), Web.routes.url(:root), target: '_blank'

    .row.my-3
      div class=col_name
        | 発行日時:
      div class=col_value
        = Time.now.strftime('%Y年%m月%d日 %H時%M分%S秒')

    .d-print-none
      p
        | 上記の初回パスワードは
        strong 現在の画面にのみ
        | 表示され、どこにも保存されていません。
        | このページを印刷して、利用者に渡してください。

      = link_to 'ユーザーの画面に戻る', routes.path(:user, user.name)

    .d-none.d-print-block
      p
        strong この通知書を受け取ったら、必ずパスワード変更を実施してください。

      p 上記アカウント管理サイトにアクセスし、「ログイン」ボタンから初回パスワードでログインを実施してください。ログイン後、「パスワード変更」からパスワードを変更してください。

      p この用紙はアカウント発行の承認書ではありません。パスワード変更後は直ちに破棄してください。

      p
        | 文字のサンプル
        br
        code.login-info
          = ('0'..'9').to_a.join(' ')
          br
          = ('A'..'Z').to_a.join(' ')
          br
          = ('a'..'z').to_a.join(' ')
          br
          = (('!'..'/').to_a + (':'..'@').to_a + ('['..'`').to_a + ('{'..'~').to_a).join(' ')

      hr

      - if current_config&.contact_name&.size&.positive?
        h5 管理者の連絡先
        .row.my-1
          div class=col_name
            | 管理者:
          div class=col_value
            = current_config&.contact_name
        - if current_config&.contact_email&.size&.positive?
          .row.my-1
            div class=col_name
              | メールアドレス:
            div class=col_value
              = link_to current_config&.contact_email, "mailto:#{current_config&.contact_email}"
        - if current_config&.contact_phone&.size&.positive?
          .row.my-1
            div class=col_name
              | 電話番号:
            div class=col_value
              = current_config&.contact_phone
