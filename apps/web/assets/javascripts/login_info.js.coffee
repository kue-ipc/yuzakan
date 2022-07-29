import {app, text} from './hyperapp.js'
import * as html from './hyperapp-html.js'
import {DateTime} from './luxon.js'

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
      html.h3 {}, text "#{site.name} ログイン情報 通知"

      dlh.dl {}, [
        dlh.dt {}, text 'アカウント名'
        dlh.dd {},
          html.code {class: 'login-info'},
            text user.username.replace(/ /g, '\u2423')

        dlh.dt {}, text 'パスワード'
        dlh.dd {},
          html.code {class: 'login-info'},
            text user.password.replace(/ /g, '\u2423')

        dlh.dt {}, text 'ログインサイト'
        dlh.dd {},
          html.a {
            target: '_blank'
            href: site.url
          }, [
            text site.name
            BsIcon {name: 'box-arrow-up-right', class: 'ms-1 d-print-none', size: 16}
            html.span {class: 'd-none d-print-inline ms-1'}, text site.url
          ]

        dlh.dt {}, text '発行日時'
        dlh.dd {}, text dateTime.toLocaleString(DateTime.DATETIME_FULL)
      ]

      @displayChars()

      html.div {class: 'd-print-none'}, [
        html.p {}, [
          text '上記の初回パスワードは'
          html.strong {}, text '現在の画面にのみ'
          text '表示され、どこにも保存されていません。'
          text '今すぐログインするか、下部の「印刷」ボタンからこのページを印刷してください。'
        ]
      ]

      html.h4 {}, text 'ログインとパスワード'
      html.p {},
        html.strong {}, text '必ずパスワードを変更してください。'
      html.p {}, [
        text '上記ログインサイトにアクセス'
        html.span {class: 'd-print-none'}, text '(新しいタブで開きます)'
        text 'し、アカウント名とパスワードでログインしてください。'
        if @service.required_new_password
          text '''
            初回ログイン時に、パスワード変更が求められます。
            メッセージに従って、パスワードを変更してください。
          '''
        else
          switch @service.name
            when 'google'
              text '''
                ログイン後、「セキュリティ」の「Google へのログイン」にある「パスワード」から
                パスワードを変更してください。
              '''
            when 'microsoft'
              text '''
                ログイン後、「パスワード」にある「パスワードの変更」からパスワードを変更してください。'
              '''
            else
              text 'ログイン後、「パスワード変更」からパスワードを変更してください。'
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

      html.h4 {}, text 'トラブルシューティング'
      switch @service.name
        when 'google'
          html.p {},
            html.strong {}, text 'ログイン画面が表示されない場合'
          html.p {},
            text '''
              すでに個人または他組織のGoogle アカウントでログインしている場合は、
              右上のアバターアイコン(デフォルトは名前一文字)をクリックし、
              「別のアカウントを追加」を押して、ログイン画面を表示してください。
            '''
        when 'microsoft'
          html.p {},
            strong {}, text 'ログイン画面が表示されない場合'
          html.p {},
            text '''
              すでに他組織のMicrosoft アカウントでログインしている場合は、
              右上のアバターアイコン(デフォルトは名札に丸)をクリックし、
              「別のアカウントでサインインする」を押して、ログイン画面を表示してください。
            '''

      html.div {class: 'd-none d-print-block'}, [
        html.p {}, text 'この用紙はアカウント発行の承認書ではありません。パスワード変更後は直ちに破棄してください。'
        html.p {}, text 'この用紙は拾得した場合は、下記連絡先に連絡をお願いします。'
        html.h4 {}, text '管理者の連絡先'
        dlh.dl {}, [
          dlh.dt {}, text '管理者'
          dlh.dd {}, text system.contact_name
          dlh.dt {}, text 'メールアドレス'
          dlh.dd {}, text system.contact_email
          dlh.dt {}, text '電話番号'
          dlh.dd {}, text system.contact_phone
        ]
      ]
    ]

  displayChars: ->
    html.div {class: 'd-print-block'}, [
      html.p {class: 'text-center'}, [
        text '文字のサンプル'
        html.br {}
        html.code {class: 'login-info'}, [
          text '0 1 2 3 4 5 6 7 8 9'
          html.br {}
          text 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z'
          html.br {}
          text 'a b c d e f g h i j k l m n o p q r s t u v w x y z'
          html.br {}
          text '\u2423 ! " # $ % & \' ( ) * + , - . / : ; < = > ? @ [ \\ ] ^ _ ` { | } ~'
        ]
      ]
    ]
