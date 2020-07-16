# フォームにあるデータをJSONとしてPOSTし、
# 受け取ったJSONをメッセージとして表示する。
# その際、modalを使用する。

import {h, app} from './hyperapp.js'
import bsn from './bootstrap-native.js'
import {FaIcon} from './fa_icon.js'

export default class WebPostJson
  MESSAGE_EVENT = 'webpostjson.message'

  constructor: ({
    @form
    @title
    @messages = {}
    @successLink = null
    @reloadTime = 0
  }) ->
    @modalNode = document.createElement('div')
    @modalNode.className = 'modal'
    @modalNode.setAttribute('tabindex', -1)
    @modalNode.setAttribute('role', 'dialog')
    @modalNode.setAttribute('aria-hidden', 'true')

    @modalChildNode = document.createElement('div')
    @modalNode.appendChild(@modalChildNode)
    document.body.appendChild(@modalNode)

    @modal = new bsn.Modal(@modalNode)

    app
      init: {
        status: 'unknown'
        title: 'no title'
        messages: 'n/a'
        closable: false
        successLink: null
      }
      view: ModalView
      node: @modalChildNode
      subscriptions: (state) => [
        messageSub messageAction, node: @modalNode
      ]

  modalMessage: (state) ->
    if state.closable
      @modal.backdrop = true
      @modal.keyboard = true
    else
      @modal.backdrop = 'static'
      @modal.keyboard = false

    event = new CustomEvent(WebPostJson.MESSAGE_EVENT, detail: state)
    @modalNode.dispatchEvent(event)

  submitPromise: () ->
    @modalMessage
      status: 'running'
      title: "#{@title}中"
      messages: @messages.running
      closable: false
    @modal.backdrop = 'static'
    @modal.keyboard = false
    @modal.show()

    try
      formData = new FormData(@form)
      response = await fetch @form.action,
        method: 'POST'
        mode: 'same-origin'
        credentials: 'same-origin'
        headers:
          'Accept': 'application/json'
        body: formData

      data =
        if response.ok
          await response.json()
        else
          console.warn(await response.text())
          {
            result: 'error'
            messages:
              failure: 'サーバー側でエラーが発生、または、接続を拒否されました。'
              errors: ["サーバーメッセージ: #{response.statusText}"]
          }

      resultTitle =
        switch data.result
          when 'success' then '成功'
          when 'failure' then '失敗'
          when 'error' then 'エラー'
          else ''



      if data.result == 'success'
        @modalMessage
          status: 'success'
          title: "#{@title}#{resultTitle}"
          closable: false
          successLink: @successLink
          messages: [
            data.messages.success
            @messages[data.result]
          ]
        setTimeout =>
          location.href = @successLink
        , @reloadTime
        return data
      else
        @modalMessage
          status: data.result
          title: "#{@title}#{resultTitle}"
          closable: true
          successLink: null
          messages: [
            data.messages.failure
            (data.messages.errors ? [])...
            @messages[data.result]
          ]
        return data

    catch error
      console.error error
      data =
        result: 'error'
        messages:
          failure: 'サーバー接続時にエラーが発生しました。しばらく待ってから、再度試してください。'

      @modalMessage
        status: 'error'
        title: '接続エラー'
        closable: true
        successLink: null
        messages: [
          data.messages.failure
          (data.messages.errors ? [])...
          @messages[data.result]
        ]
      return data

messageRunner = (dispatch, {action, node}) ->
  func = (e) ->
    dispatch(action, e.detail)
  node.addEventListener(WebPostJson.MESSAGE_EVENT, func)
  () -> node.removeEventListener(WebPostJson.MESSAGE_EVENT, func)

messageSub = (action, {node}) ->
  [
    messageRunner
    {action, node}
  ]

messageAction = (state, params) -> {
  state...
  params...
}

ModalView = ({status, title, messages, closable, successLink}) ->
  h 'div', class: 'modal-dialog modal-dialog-centered', role: 'document',
    h 'div', class: 'modal-content',
      h 'div', class: 'modal-header',
        h 'h5', class: 'modal-title',
          h StatusIcon, status: status
          ' '
          title
        if closable
          h 'button',
            class: 'close'
            type: 'button'
            'data-dismiss': 'modal'
            'aria-label': "閉じる"
            h 'span', 'aria-hidden': "true",
              h FaIcon, prefix: 'fas', name: 'fa-times'
      h 'div', class: 'modal-body',
        h MessageList, messages: messages
      if closable || successLink?
        h 'div', class: 'modal-footer',
          if successLink?
            h 'a',
              class: 'btn btn-primary'
              role: 'button'
              href: successLink
              'すぐに移動'
          if closable
            h 'button',
              class: 'btn btn-secondary'
              type: 'button'
              'data-dismiss': 'modal'
              '閉じる'

StatusIcon = ({status}) ->
  [textClass, props] =
    switch status
      when 'running'
        [
          'text-primary'
          {prefix: 'fas', name: 'fa-spinner', options: ['fa-spin']}
        ]
      when 'success'
        [
          'text-success'
          {prefix: 'fas', name: 'fa-check'}
        ]
      when 'failure'
        [
          'text-danger'
          {prefix: 'fas', name: 'fa-times'}
        ]
      when 'error'
        [
          'text-warning'
          {prefix: 'fas', name: 'fa-exclamation-triangle'}
        ]
      else
        [
          'text-secondary'
          {prefix: 'fas', name: 'fa-question'}
        ]
  h 'span', class: textClass,
    h FaIcon, props

MessageList = ({messages}) ->
  messages = [messages] unless messages instanceof Array
  h 'div', {}, messages.filter((x) -> typeof x == 'string').map (msg) ->
    h 'div', {}, msg
