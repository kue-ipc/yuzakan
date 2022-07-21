import {Modal} from './bootstrap.js'
import {app, text} from './hyperapp.js'
import * as html from './hyperapp-html.js'
import {modalDialog} from './modal.js'

export default class ModalDialog
  MESSAGE_EVENT = 'modaldialog.message'

  constructor: ({
    @id
    @fade = true
    @scrollable = false
    @centered = false
    @size = undefined
    @fullscreen = undefined
    @title
    @status = 'info'
    @closable = true
    action = {}
    close = {}
  }) ->
    @action = {
      color: 'primary'
      label: 'OK'
      side: 'right'
      action...
    }
    @close = {
      color: 'secondary'
      label: 'キャンセル'
      close...
    }

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
      init: {
        title: @title
        messages: @messages
        value: ''
      }
      view: @modalView
      node: modalDialogNode
      subscriptions: (state) => [
        @messageSub @messageAction, {node: @modalNode}
        @shownSub (state) -> {state..., shown: true}
        @hiddenSub (state) -> {state..., shown: false}
      ]
    }

  modalView: ({action, modal = {}, ...props}) =>
    modalDialog {
      id: @id
      scrollable: @scrollable
      centered: @centered
      size: @size
      fullscreen: @fullscreen
      title: @title
      status: @status
      closable: @closable
      action: {
        @action...
        modal.action...
        onclick: action
      }
      close: @close
      modal...
    }, @modalBody props

  # overwrite
  modalBody: (props) ->
    throw new Error('Not implemented')

  fireModalMessage: (state) ->
    event = new CustomEvent(ModalDialog.MESSAGE_EVENT, {detail: state})
    @modalNode.dispatchEvent(event)

  messageRunner: (dispatch, {action, node}) ->
    func = (e) -> dispatch(action, e.detail)
    node.addEventListener(ModalDialog.MESSAGE_EVENT, func)
    -> node.removeEventListener(ModalDialog.MESSAGE_EVENT, func)

  messageSub: (action, {node}) => [@messageRunner, {action, node}]

  messageAction: (state, params) =>
    [{state..., params...}, focus("#{@id}-input-textarea")]

  shownRunner: (dispatch, {action}) =>
    func = -> dispatch(action)
    @modalNode.addEventListener('shown.bs.modal', func)
    => @modalNode.removeEventListener('shown.bs.modal', func)

  shownSub: (action) => [@shownRunner, {action}]

  hiddenRunner: (dispatch, {action}) =>
    func = -> dispatch(action)
    @modalNode.addEventListener('hidden.bs.modal', func)
    => @modalNode.removeEventListener('hidden.bs.modal', func)

  hiddenSub: (action) => [@hiddenRunner, {action}]

  promise: (props)
  inputPromise: ({messages, value}) ->
    @fireModalMessage({messages, value})
    @result = null
    @modal.show()

    await @waitModalClose()

    return @result

  waitModalClose: =>
    new Promise (resolve, reject) =>
      @modalNode.addEventListener 'hidden.bs.modal', ->
        resolve()
      , {once: true}
