# データをJSONとしてfetchし、受け取ったJSONをメッセージとして表示する。
# その際、modalを使用する。

import {h, text, app} from './hyperapp.js?v=0.6.0'
import {Modal} from './bootstrap.js?v=0.6.0'
import {StatusIcon, statusInfo} from './status.js?v=0.6.0'
import {fetchJson} from './fetch_json.js?v=0.6.0'

export default class WebData
  MESSAGE_EVENT = 'webdata.message'

  constructor: ({
    @title
    @method = 'GET'
    @url = null
    @statusActions = new Map
  }) ->
    @modalNode = document.createElement('div')
    @modalNode.classList.add('modal')
    @modalNode.setAttribute('tabindex', -1)
    @modalNode.setAttribute('aria-hidden', 'true')

    modalDialogNode = document.createElement('div')
    modalDialogNode.classList.add('modal-dialog', 'modal-dialog-centered')

    modalContentNode = document.createElement('div')
    modalContentNode.classList.add('modal-content')

    modalDialogNode.appendChild(modalContentNode)
    @modalNode.appendChild(modalDialogNode)
    document.body.appendChild(@modalNode)

    @modal = new Modal(@modalNode)

    app {
      init: {
        status: 'unknown'
        title: 'no title'
        messages: 'n/a'
        closable: true
      }
      view: @modalView
      node: modalContentNode
      subscriptions: (state) => [
        @messageSub @messageAction, {node: @modalNode}
      ]
    }

  modalView: ({status, title, messages, closable}) =>
    h 'div', {class: 'modal-content'}, [
      h 'div', {class: 'modal-header'}, [
        h 'h5', {class: 'modal-title'}, [
          StatusIcon {status: status}
          text " #{title}"
        ]
        if closable
          h 'button', {
            class: 'btn-close'
            type: 'button'
            'data-bs-dismiss': 'modal'
            'aria-label': "閉じる"
          }
      ]
      h 'div', {class: 'modal-body'},
        @messageList {messages: messages}
      if closable || successLink?
        h 'div', {class: 'modal-footer'}, [
          if successLink?
            h 'a', {
              class: 'btn btn-primary'
              role: 'button'
              href: successLink
            }, text 'すぐに移動'
          if closable
            h 'button', {
              class: 'btn btn-secondary'
              type: 'button'
              'data-bs-dismiss': 'modal'
            }, text '閉じる'
        ]
    ]

  messageList: ({messages}) ->
    messages = [messages] unless messages instanceof Array
    h 'div', {}, messages.filter((x) -> typeof x == 'string').map (msg) ->
      h 'div', {},
        text msg

  modalMessage: (state) ->
    # hack modal config
    # https://github.com/twbs/bootstrap/issues/35664
    if state.closable
      @modal._config.backdrop = true
      @modal._config.keyboard = true
    else
      @modal._config.backdrop = 'static'
      @modal._config.keyboard = false

    event = new CustomEvent(WebData.MESSAGE_EVENT, {detail: state})
    @modalNode.dispatchEvent(event)

  messageRunner: (dispatch, {action, node}) ->
    func = (e) -> dispatch(action, e.detail)
    node.addEventListener(WebData.MESSAGE_EVENT, func)
    -> node.removeEventListener(WebData.MESSAGE_EVENT, func)

  messageSub: (action, {node}) => [@messageRunner, {action, node}]

  messageAction: (state, params) -> {state..., params...}

  submitPromise: ({url = @url, method = @method, data, type}) ->
    @modalMessage {
      status: 'running'
      title: "#{@title}中"
      messages: "#{@title}を実施しています。しばらくお待ち下さい。"
      closable: false
    }
    @modal.backdrop = 'static'
    @modal.keyboard = false
    @modal.show()

    try
      response = await fetchJson {url, method, data, type}

      switch response.type
        when 'json'
          responseData = response.data
        when 'text'
          responseData = {
            result: 'fatal'
            messeage: 'サーバーの処理で致命的なエラーが発生しました。'
            errors: [response.data]
          }
        else
          throw new Error("Unsupported respose type: #{response.type}")

    catch error
      console.error error
      responseData = {
        result: 'error'
        message: 'サーバー接続時にエラーが発生しました。しばらく待ってから、再度試してください。'
      }

    messages = [responseData.message, (responseData.errors ? [])...]

    statusAction = @statusActions.get(responseData.result)
    messages.push(statusAction?.message) if statusAction?.message?

    if statusAction?.redirectTo?
      closable = false
      link = statusAction.redirectTo
      messages.push('画面を切り替えます。しばらくお待ち下さい。')
    else
      closable = true
      link = null

    @modalMessage {
      status: responseData.result
      title: "#{@title}#{statusInfo(responseData.result).label}"
      closable
      link
      messages
    }
    if link?
      setTimeout =>
        location.href = @link
      , statusAction?.reloadTime ? 0

    return responseData
