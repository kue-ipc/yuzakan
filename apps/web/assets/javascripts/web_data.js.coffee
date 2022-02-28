# データをJSONとしてfetchし、受け取ったJSONをメッセージとして表示する。
# その際、modalを使用する。

import {app, text} from './hyperapp.js?v=0.6.0'
import {focus} from './hyperapp-dom.js?v=0.6.0'
import {div, h5, a, button} from './hyperapp-html.js?v=0.6.0'
import {Modal} from './bootstrap.js?v=0.6.0'
import {StatusIcon, statusInfo} from './status.js?v=0.6.0'
import {fetchJson} from './fetch_json.js?v=0.6.0'
import {modalDialog} from './modal.js?v=0.6.0'

export default class WebData
  MESSAGE_EVENT = 'webdata.message'
  DEFAULT_CODE_ACTIONS = new Map [
    [0, {status: 'error', 'サーバー接続時にエラーが発生しました。しばらく待ってから、再度試してください。'}]
    [500, {status: 'fatal', message: 'サーバー側で致命的なエラーが発生しました。管理者に連絡してください。'}]
  ]
  UNKNOWN_CODE_ACTION = {status: 'unknown', message: 'サーバーから不明なコードが返されました。'}

  constructor: ({
    @id
    @title
    @method = 'GET'
    @url = null
    codeActions = []
  }) ->
    @codeActions = new Map [DEFAULT_CODE_ACTIONS..., codeActions...]

    @modalNode = document.createElement('div')
    @modalNode.id = "#{@id}-modal"
    @modalNode.classList.add('modal')
    @modalNode.setAttribute('tabindex', -1)
    @modalNode.setAttribute('aria-hidden', 'true')

    modalDialogNode = document.createElement('div')
    @modalNode.id = "#{@id}-modal-dialog"
    modalDialogNode.classList.add('modal-dialog', 'modal-dialog-centered')

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
      node: modalDialogNode
      subscriptions: (state) => [
        @messageSub @messageAction, {node: @modalNode}
      ]
    }
  
  modalView: ({status, title, messages, closable, link}) =>
    modalDialog {
      id: @id,
      centered: true
      title: title
      status
      closable
      action: if link? then {
        label: 'すぐに移動する'
        color: 'primary'
        onclick: (state) -> [state, [ -> location.href = link]]
      }
    }, @messageList {messages: messages}

  messageList: ({messages}) ->
    messages = [messages] unless messages instanceof Array
    div {}, messages.filter((x) -> typeof x == 'string').map (msg) ->
      div {}, text msg

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

  messageAction: (state, params) =>
    newState = {state..., params...}
    if newState.closable
      [newState, focus("#{@id}-modal-close-button")]
    else
      newState

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
    catch error
      console.error error
      response = {
        ok: false
        code: 0
        type: 'json'
        data: {
          message: 'サーバー接続時にエラーが発生しました。しばらく待ってから、再度試してください。'
        }
      }

    responseData =
      switch response.type
        when 'json'
          response.data
        when 'text'
          {
            message: response.data
          }
        when null, undefined
          {}
        else
          console.error "Unsupported respose type: #{response.type}"
          responseData = {
            message: '異常なレスポンスが返されました。再度試してください。'
          }

    codeAction = @codeActions.get(response.code) || UNKNOWN_CODE_ACTION

    messages = [codeAction.message, responseData.message, (responseData.errors ? [])...].filter((v) -> v?)

    if codeAction?.redirectTo?
      closable = false
      link = codeAction.redirectTo
      if codeAction.reloadTime? and codeAction.reloadTime > 0
        reloadDelay = codeAction.reloadTime * 1000
        messages.push("約#{codeAction.reloadTime}秒後に画面を切り替えます。")
      else
        reloadDelay = 0 # default 0 msec
        messages.push('画面を切り替えます。しばらくお待ち下さい。')
    else
      closable = true
      link = null

    @modalMessage {
      status: codeAction.status
      title: "#{@title}#{statusInfo(codeAction.status).label}"
      messages
      closable
      link
    }
    if link?
      setTimeout ->
        location.href = link
      , reloadDelay

    await @waitModalClose()

    return responseData

  waitModalClose: =>
    new Promise (resolve, reject) =>
      @modalNode.addEventListener 'hidden.bs.modal', ->
        resolve()
      , {once: true}