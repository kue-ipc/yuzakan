import {Modal} from './bootstrap.js'
import {app, text} from './hyperapp.js'
import * as html from './hyperapp-html.js'
import {modalDialog} from './modal.js'

export default class InputTextDialog
  MESSAGE_EVENT = 'inputtextdialog.message'

  constructor: ({
    @id
    @title
    @messages = []
    @siza
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
    @modalNode.classList.add('modal', 'fade')
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
        title: @title
        messages: @messages
        value: ''
        size: @size
        action: @action
        close: @close
      }
      view: @modalView
      node: modalDialogNode
      subscriptions: (state) => [
        @messageSub @messageAction, {node: @modalNode}
      ]
    }

  modalView: ({title, messages, value, size, action, close}) =>
    modalDialog {
      id: @id,
      title
      closable: true
      action:
        {
          action...
          onclick: (state) =>
            @result = value
            @modal.hide()
            state
        }
      close: @close
    }, @modalBody {messages, value, size}

  modalBody: ({messages, value, size}) ->
    html.div {}, [
      (html.p({}, text message) for message in messages)...
      html.textarea {
        id: "#{@id}-input-textarea"
        maxlength: size
        oninput: (state, event) -> {state..., value: event.target.value}
      }, text value
    ]

  fireModalMessage: (state) ->
    event = new CustomEvent(InputTextDialog.MESSAGE_EVENT, {detail: state})
    @modalNode.dispatchEvent(event)

  messageRunner: (dispatch, {action, node}) ->
    func = (e) -> dispatch(action, e.detail)
    node.addEventListener(InputTextDialog.MESSAGE_EVENT, func)
    -> node.removeEventListener(InputTextDialog.MESSAGE_EVENT, func)

  messageSub: (action, {node}) => [@messageRunner, {action, node}]

  messageAction: (state, params) =>
    [{state..., params...}, focus("#{@id}-input-textarea")]

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
