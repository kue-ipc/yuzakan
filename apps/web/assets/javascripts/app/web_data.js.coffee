# データをJSONとしてfetchし、受け取ったJSONをメッセージとして表示する。
# その際、modalを使用する。

import {app, text} from 'hyperapp'
import * as html from '@hyperapp/html'
import {focus} from '@hyperapp/dom'
import {Modal} from 'bootstrap'
import {StatusIcon, statusInfo} from '~/app/status.js'
import {fetchJson} from '~/api/fetch_json.js'
import {modalDialog} from '~/app/modal.js'

export default class WebData
  MESSAGE_EVENT = 'webdata.message'
  DEFAULT_CODE_ACTIONS = new Map [
    [0, {status: 'error'}]
    [400, {status: 'error', message: 'パラメーターが不正です。'}]
    [401, {status: 'error', message: 'ログインが必要です。', reload: true}]
    [403, {status: 'error', message: 'アクセスする権限がありません。', reload: true}]
    [422, {status: 'failure', message: '失敗しました。'}]
    [500, {
      status: 'fatal'
      message: 'サーバー側で致命的なエラーが発生しました。管理者に連絡してください。'
      reload: true
    }]
  ]
  UNKNOWN_CODE_ACTION = {status: 'unknown'}

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
    modalDialogNode.id = "#{@id}-modal-dialog"
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
        link: null
        reload: false
      }
      view: @modalView
      node: modalDialogNode
      subscriptions: (state) => [
        @messageSub @messageAction, {node: @modalNode}
      ]
    }

  modalView: ({status, title, messages, closable, link, reload}) =>
    modalDialog {
      id: @id,
      centered: true
      title
      status
      closable
      action: if link?
        {
          label: 'すぐに移動する'
          color: 'primary'
          onclick: (state) -> [state, [ -> location.href = link]]
        }
      else if reload
        {
          label: 'ページの再読み込み'
          color: 'danger'
          onclick: (state) -> [state, [ -> location.reload()]]
        }
    }, @messageList {messages: messages}

  messageList: ({messages}) ->
    messages = [messages] unless messages instanceof Array
    html.div {}, messages.filter((x) -> typeof x == 'string').map (msg) ->
      html.div {}, text msg

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
      link: null
      reload: false
    }
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

    messages = [(codeAction.message || responseData.message), (responseData.errors ? [])...]
      .filter (v) -> typeof v == 'string'

    if codeAction?.redirectTo?
      closable = false
      link = codeAction.redirectTo
      if codeAction.reloadTime? and codeAction.reloadTime > 0
        reloadDelay = codeAction.reloadTime * 1000
        messages.push("約#{codeAction.reloadTime}秒後に画面を切り替えます。")
      else
        reloadDelay = 0 # default 0 msec
        messages.push('画面を切り替えます。しばらくお待ち下さい。')
    else if codeAction?.reload
      closable = false
      link = null
      reload = true
    else
      closable = true
      link = null
      reload = false

    @modalMessage {
      status: codeAction.status
      title: "#{@title}#{statusInfo(codeAction.status).label}"
      messages
      closable
      link
      reload
    }

    if link?
      setTimeout ->
        location.href = link
      , reloadDelay
    else if codeAction?.autoCloseTime
      setTimeout =>
        @modal.hide()
      , codeAction.autoCloseTime * 1000

    await @waitModalClose()

    return response

  waitModalClose: =>
    new Promise (resolve, reject) =>
      @modalNode.addEventListener 'hidden.bs.modal', ->
        resolve()
      , {once: true}
