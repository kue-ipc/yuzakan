# データをJSONとしてfetchし、受け取ったJSONをメッセージとして表示する。
# その際、modalを使用する。

import {h, text, app} from './hyperapp.js?v=0.6.0'
import {Modal} from './bootstrap.js?v=0.6.0'
import {StautsIcon, statusInfo} from './status.js?v=0.6.0'
import {fetchJsonPost} from './fetch_json.js?v=0.6.0'

export default class WebData
  MESSAGE_EVENT = 'webdata.message'

  constructor: ({
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

    event = new CustomEvent(WebData.MESSAGE_EVENT, detail: state)
    @modalNode.dispatchEvent(event)

  submitPromise: ({url = @url, method = @method, data = null}) ->
    @modalMessage
      status: 'running'
      title: "#{@title}中"
      messages: "#{@title}を実施しています。しばらくお待ち下さい。"
      closable: false
    @modal.backdrop = 'static'
    @modal.keyboard = false
    @modal.show()

    try
      formData = new FormData(@form)

      renponse = await fetchJsonPost @form.action, body: formData
      data = response.data

      resultTitle = statusInfo(data.result).label

      if data.result == 'success'
        @modalMessage
          status: data.result
          title: "#{@title}#{resultTitle}"
          closable: false
          successLink: @successLink
          messages: [
            data.message
            '画面を切り替えます。しばらくお待ち下さい。'
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
            data.message
            (data.errors ? [])...
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
  node.addEventListener(WebData.MESSAGE_EVENT, func)
  () -> node.removeEventListener(WebData.MESSAGE_EVENT, func)

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

MessageList = ({messages}) ->
  messages = [messages] unless messages instanceof Array
  h 'div', {}, messages.filter((x) -> typeof x == 'string').map (msg) ->
    h 'div', {},
      text msg
