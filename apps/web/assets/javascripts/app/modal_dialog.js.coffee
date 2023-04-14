# ModaleDialog
# モーダルダイアログを表示するベースクラス
# 拡張して使用する

import {app, text} from '~/vendor/hyperapp.js'
import * as html from '~/vendor/hyperapp-html.js'
import {focus} from '~/vendor/hyperapp-dom.js'

import {Modal} from '~/vendor/bootstrap.js'

import {modalDialog} from '~/app/modal.js'

export default class ModalDialog
  MESSAGE_EVENT = 'modaldialog.message'

  DEFAULT_ACTION = Object.freeze {
    color: 'primary'
    label: 'OK'
    side: 'right'
  }

  DEFAULT_CLOSE = Object.freeze {
    color: 'secondary'
    label: '閉じる'
  }

  constructor: ({
    @id
    @fade = true
    @scrollable = true
    @centered = false
    @size # 'sm', 'lg', 'xl'
    @fullscreen # true, 'sm-down', 'md-down', 'lg-down', 'xl-down', 'xxl-down'
    @title
    @status # see status.js
    @closable = true
    action = {}
    close = {}
    @messages = []
    @value
  }) ->
    @action = if action then {ModalDialog.DEFAULT_ACTION..., action...} else null
    @close = if close then {ModalDialog.DEFAULT_CLOSE..., close...} else null
    @result = undefined

    @initNode()

  # モーダルウィンドウのノードを作成し、初期化する。
  initNode: ->
    @modalNode = document.createElement('div')
    @modalNode.id = "#{@id}-modal"
    @modalNode.classList.add('modal')
    @modalNode.classList.add('fade') if @fade
    @modalNode.setAttribute('tabindex', -1)
    @modalNode.setAttribute('aria-hidden', 'true')

    modalDialogNode = document.createElement('div')
    modalDialogNode.id = "#{@id}-modal-dialog"
    modalDialogNode.classList.add('modal-dialog')

    @modalNode.appendChild(modalDialogNode)
    document.body.appendChild(@modalNode)

    @modal = new Modal(@modalNode)

    app {
      init: @appInit()
      view: @modalView
      node: modalDialogNode
      subscriptions: (state) => [
        ModalDialog.onMessage @modalNode, @receiveModalMessage
        ModalDialog.onShown @modalNode, (state) -> [{state..., shown: true}, focus(state.focus)]
        ModalDialog.onHidden @modalNode, (state) -> {state..., shown: false}
      ]
    }

  appInit: => @initState

  modalView: ({title, status, closable, action, close, props...}) =>
    modalDialog {
      id: @id
      scrollable: @scrollable
      centered: @centered
      size: @size
      fullscreen: @fullscreen
      title
      status
      closable
      action
      close
    }, @modalBody {props...}

  modalAction: (state) =>
    @result = state.value
    [state, @hideModal]

  hideModal: (_dispatch) => @modal.hide()

  modalBody: ({messages}) ->
    html.p {}, text message for message in messages ? []

  # fire event
  fireModalMessage: (props) ->
    event = new CustomEvent(ModalDialog.MESSAGE_EVENT, {detail: props})
    @modalNode.dispatchEvent(event)

  # Actions
  receiveModalMessage: (state, props) ->
    {state..., props...}

  initState: (state) => {
    title: @title
    status: @status
    closable: @closable
    action: if @action then {@action..., onclick: @modalAction} else null
    close: @close
    messages: @messages
    value: @value
    shwon: false
    focus: "#{@id}-modal-close-button"
    state...
  }

  # show
  showPromise: (state = {}) ->
    state = @initState(state)
    @fireModalMessage(state)
    @result = undefined
    waitModalClose = @waitModalClosePromise()
    # hack modal config
    # https://github.com/twbs/bootstrap/issues/35664
    if state.closable
      @modal._config.backdrop = true
      @modal._config.keyboard = true
    else
      @modal._config.backdrop = 'static'
      @modal._config.keyboard = false
    @modal.show()

    await waitModalClose

    return @result
  
  hide: ->
    @modal.hide()

  waitModalClosePromise: ->
    new Promise (resolve, reject) =>
      @modalNode.addEventListener 'hidden.bs.modal', ->
        resolve()
      , {once: true}

  # Static Methods
  # Create Subscription
  @onMessage: (node, action) => [@listenMessage, {node, action}]
  @onShown: (node, action) => [@listenShown, {node, action}]
  @onHidden: (node, action) => [@listenHidden, {node, action}]

  # SubscriberFn
  @listenMessage: (dispatch, {node, action}) =>
    func = (e) -> dispatch(action, e.detail)
    node.addEventListener(@MESSAGE_EVENT, func)
    -> node.removeEventListener(@MESSAGE_EVENT, func)
  @listenShown: (dispatch, {node, action}) ->
    func = -> dispatch(action)
    node.addEventListener('shown.bs.modal', func)
    -> node.removeEventListener('shown.bs.modal', func)
  @listenHidden: (dispatch, {node, action}) ->
    func = -> dispatch(action)
    node.addEventListener('hidden.bs.modal', func)
    -> node.removeEventListener('hidden.bs.modal', func)
