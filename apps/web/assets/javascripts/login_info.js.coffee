import {app, text} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'
import {DateTime} from '/assets/vendor/luxon.js'

import ModalDialog from './modal_dialog.js'
import BsIcon from './bs_icon.js'
import * as dlh from './dl_horizontal.js'

import {runGetSystem} from './api/get_system.js'

export default class LoginInfo extends ModalDialog
  constructor: ({service = {}, props...}) ->
    super {
      title: 'ログイン情報'
      fullscreen: 'xl-down'
      size: 'xl'
      action: {
        color: 'success'
        label: '印刷'
        side: 'left'
      }
      props...,
    }
    @service = service

  # override
  appInit: => [@initState({}), runGetSystem]

  # override
  modalAction: (state) ->
    for tagName in ['header', 'main', 'footer']
      for el in document.getElementsByTagName(tagName)
        el.classList.add('d-print-none')
    for className in ['modal-header', 'modal-footer']
      for el in document.getElementsByClassName(className)
        el.classList.add('d-print-none')
    window.print()
    for tagName in ['header', 'main', 'footer']
      for el in document.getElementsByTagName(tagName)
        el.classList.remove('d-print-none')
    for className in ['modal-header', 'modal-footer']
      for el in document.getElementsByClassName(className)
        el.classList.remove('d-print-none')
    state

  # override
  modalBody: ({messages, props...}) ->
    [
      super({messages})...
      if props.user? && props.system?
        html.div {class: 'boder print-fullscreen'},
          @loginInfo(props)
    ]

  loginInfo: ({user, dateTime, system}) ->
    site = switch @service.name
      when 'google'
        {name: 'Google アカウント', url: 'https://accounts.google.com/'}
      when 'microsoft'
        {name: 'Microsoft アカウント', url: 'https://myaccount.microsoft.com/'}
      else
        {name: system.title, url: system.url}

    html.div {}, [
      html.h3 {}, text "#{site.name} ログイン情報 通知書"

      dlh.dl {}, [
        dlh.dt {}, text 'ユーザー名'
        dlh.dd {},
          html.code {class: 'login-info'},
            text user.name.replace(/ /g, '\u2423')

        dlh.dt {}, text '初期パスワード'
        dlh.dd {},
          html.code {class: 'login-info'},
            text user.password.replace(/ /g, '\u2423')

        dlh.dt {}, text 'ログインサイト'
        dlh.dd {class: 'd-print-none'},
          html.a {
            target: '_blank'
            href: site.url
          }, [
            text site.name
            BsIcon {name: 'box-arrow-up-right', class: 'ms-1 d-print-none', size: 16}
          ]
        dlh.dd {class: 'd-none d-print-block'},
          text site.name
        dlh.ddSub {class: 'd-none d-print-block'},
          text site.url

        dlh.dt {}, text '発行日時'
        dlh.dd {}, text dateTime.toLocaleString(DateTime.DATETIME_FULL)
      ]

      @displayChars()

      html.hr {}

      html.div {class: 'd-print-none'}, [
        html.p {}, [
          text '上記の初期パスワードは'
          html.strong {}, text '現在の画面にのみ'
          text '表示され、どこにも保存されていません。'
          text '今すぐログインするか、下部の「印刷」ボタンからこのページを印刷してください。'
        ]
      ]

      html.p {},
        html.strong {}, text 'システムの利用にはパスワード変更が必要です。'
      html.p {}, [
        text '上記ログインサイトにアクセス'
        html.span {class: 'd-print-none'}, text '(新しいタブで開きます)'
        text 'し、ユーザー名とパスワードでログインしてください。'
        if @service.required_new_password
          text '''
            初回ログイン時に、パスワード変更が求められます。
            メッセージに従って、パスワードを変更してください。
          '''
        else
          switch @service.name
            when 'google'
              text '''
                すでに個人または他組織のGoogle アカウントでログインしている場合は、
                ログイン画面が表示されません。
                右上のアバターアイコン(デフォルトは名前一文字)をクリックし、
                「別のアカウントを追加」を押して、ログイン画面を表示してください。
              '''
              text '''
                ログイン後、「セキュリティ」の「Google へのログイン」にある「パスワード」から
                パスワードを変更できます。
              '''
            when 'microsoft'
              text '''
                すでに他組織のMicrosoft アカウントでログインしている場合は、
                ログイン画面が表示されません。
                右上のアバターアイコン(デフォルトは名札に丸)をクリックし、
                「別のアカウントでサインインする」を押して、ログイン画面を表示してください。
              '''
              text '''
                ログイン後、「パスワード」にある「パスワードの変更」からパスワードを変更できます。'
              '''
            else
              text 'ログイン後、「パスワード変更」からパスワードを変更できます。'
        if @service.mfa
          html.p {}, [
            text '''
              2段階認証の設定が必須です。必ず設定してください。
              設定しなかった場合、ログインできなくなります。
            '''
          ]
        if @service.lock_days
          text """
            #{sevrice.lock_days}日以内にログイン及びパスワード変更を実施しなかった場合、
            アカウントがロックされる場合があります。
          """
      ]

      html.div {class: 'd-none d-print-block'}, [
        html.hr {}
        html.p {}, text 'この通知書はアカウント発行の承認書ではありません。パスワード変更後は直ちに破棄してください。'
        html.p {}, text 'この通知書を拾得した場合は、下記連絡先に連絡をお願いします。'
        html.h4 {}, text '管理者の連絡先'
        dlh.dl {}, [
          dlh.dt {}, text '管理者'
          dlh.dd {}, text system.contact.name ? ''
          dlh.dt {}, text 'メールアドレス'
          dlh.dd {}, text system.contact.email ? ''
          dlh.dt {}, text '電話番号'
          dlh.dd {}, text system.contact.phone ? ''
        ]
      ]
    ]

  displayChars: ->
    html.div {class: 'd-print-block border rounded p-1'}, [
      html.h5 {}, text '文字サンプル'
      dlh.dl {class: 'mb-1'}, [
        dlh.dt {}, text '数字'
        dlh.dd {class: 'mb-0'},
          html.code {class: 'sample'},
            text '0 1 2 3 4 5 6 7 8 9'
        dlh.dt {}, text '大文字'
        dlh.dd {class: 'mb-0'},
          html.code {class: 'sample'},
            text 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'
        dlh.dt {}, text '小文字'
        dlh.dd {class: 'mb-0'},
          html.code {class: 'sample'},
            text 'a b c d e f g h i j k l m n o p q r s t u v w x y z'
        dlh.dt {}, text '記号'
        dlh.dd {class: 'mb-0'},
          html.code {class: 'sample'},
            text '\u2423 ! " # $ % & \' ( ) * + , - . / : ; < = > ? @ [ \\ ] ^ _ ` { | } ~'
      ]
    ]
