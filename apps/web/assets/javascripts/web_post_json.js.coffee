# フォームにあるデータをJSONとしてPOSTし、
# 受け取ったJSONをメッセージとして表示する。
# その際、modalを使用する。

import {h, app} from './hyperapp.js'
import {div, h5, button, span, i} from './hyperapp-html.js'
import bsn from './bootstrap-native.js'
import {FasIcon} from './fa_icon.js'

export default class WebPostJson
  MESSAGE_EVENT = 'webpostjson.message'

  constructor: (@form, @title, @messages = {}) ->
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

      data = await response.json()

      if data.result == 'success'
        @modalMessage
          status: 'success'
          title: "#{@title}成功"
          closable: false
          messages: [
            data.messages.success
            @messages.success
          ]
        return true
      else
        @modalMessage
          status: 'failure'
          title: "#{@title}失敗"
          closable: true
          messages: [
            data.messages.failure
            data.messages.errors...
            @messages.failure
          ]
        return false
    catch error
      @modalMessage
        status: 'error'
        title: '接続エラー'
        closable: true
        messages: [
          'サーバー接続時にエラーが発生しました。しばらく待ってから、再度試してください。'
          "エラー内容: #{error}"
          @messages.error
        ]
      throw error

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

ModalView = ({status, title, messages, closable}) ->
  div class: 'modal-dialog modal-dialog-centered', role: 'document',
    div class: 'modal-content', [
      div class: 'modal-header', [
        h5 class: 'modal-title', [
          h StatusIcon, status: status
          ' '
          title
        ]
        if closable
          button
            class: 'close'
            type: 'button'
            'data-dismiss': 'modal'
            'aria-label': "閉じる"
            span 'aria-hidden': "true",
              i class: 'fas fa-times'
      ]
      div class: 'modal-body',
        h MessageList, messages: messages
      if closable
        div class: 'modal-footer',
          button
            class: 'btn btn-secondary'
            type: 'button'
            'data-dismiss': 'modal'
            '閉じる'
    ]

StatusIcon = ({status}) ->
  span {}, [
    status
    switch status
      when 'running'
        h FasIcon, name: 'fa-spinner', options: ['fa-spin', 'text-primary'],
          status
      when 'success'
        h FasIcon, name: 'fa-check', options: ['text-success'],
          status
      when 'failure'
        h FasIcon, name: 'fa-times', options: ['text-danger'],
          status
      when 'error'
        h FasIcon, name: 'fa-exclamation-triangle', options: ['text-warning'],
          status
      else
        h FasIcon, name: 'fa-question', options: ['text-secondary'],
          status
  ]
MessageList = ({messages}) ->
  messages = [messages] unless messages instanceof Array
  div {}, messages.filter((x) -> x).map (msg) ->
    div {}, msg
