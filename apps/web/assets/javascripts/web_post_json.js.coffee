# フォームにあるデータをJSONとしてPOSTし、
# 受け取ったJSONをメッセージとして表示する。
# その際、modalを使用する。

import {h, text, app} from './hyperapp.js'
import {Modal} from './bootstrap.js'
import {BsIcon} from './bs_icon.js'

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
    @modalNode.classList.add('modal')
    @modalNode.setAttribute('tabindex', -1)
    @modalNode.setAttribute('aria-hidden', 'true')

    modalDialogNode = document.createElement('div')
    modalDialogNode.classList.add('modal-dialog', 'modal-dialog-centered')

    @modalContentNode = document.createElement('div')
    @modalContentNode.classList.add('modal-content')

    modalDialogNode.appendChild(@modalContentNode)
    @modalNode.appendChild(modalDialogNode)
    document.body.appendChild(@modalNode)

    @modal = new Modal(@modalNode)
    globalThis.modalNode = @modalNode
    globalThis.modal = @modal

    app
      init: {
        status: 'unknown'
        title: 'no title'
        messages: 'n/a'
        closable: false
        successLink: null
      }
      view: ModalView
      node: @modalContentNode
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
  h 'div', class: 'modal-content', [
    h 'div', class: 'modal-header', [
      h 'h5', class: 'modal-title', [
        StatusIcon status: status
        text " #{title}"
      ]
      if closable
        h 'button',
          class: 'btn-close'
          type: 'button'
          'data-bs-dismiss': 'modal'
          'aria-label': "閉じる"
    ]
    h 'div', class: 'modal-body',
      MessageList messages: messages
    if closable || successLink?
      h 'div', class: 'modal-footer', [
        if successLink?
          h 'a',
            class: 'btn btn-primary'
            role: 'button'
            href: successLink
            text 'すぐに移動'
        if closable
          h 'button',
            class: 'btn btn-secondary'
            type: 'button'
            'data-bs-dismiss': 'modal'
            text '閉じる'
      ]
  ]

StatusIcon = ({status}) ->
  if status == 'running'
    return h 'div', class: 'spinner-boder', role: 'status',
      h 'span', class: 'visually-hidden',
        text '読込中...'

  [textClass, props] =
    switch status
      when 'success'
        [
          'text-success'
          {name: 'check-circle-fill'}
        ]
      when 'failure'
        [
          'text-danger'
          {name: 'x-octagon-fill'}
        ]
      when 'error'
        [
          'text-warning'
          {name: 'exclamation-triangle-fill'}
        ]
      else
        [
          'text-secondary'
          {name: 'question-diamond-fill'}
        ]
  h 'span', class: textClass,
    BsIcon props

MessageList = ({messages}) ->
  messages = [messages] unless messages instanceof Array
  h 'div', {}, messages.filter((x) -> typeof x == 'string').map (msg) ->
    h 'div', {},
      text msg
